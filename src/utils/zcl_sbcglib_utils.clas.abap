class ZCL_SBCGLIB_UTILS definition
  public
  final
  create public.

  public section.

    " SPDX-License-Identifier: Apache-2.0
    " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
    " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


    class-methods uniq_list_of
      importing
        !tab type any table
        !fld type csequence
      exporting
        value(ev_result) type standard table.
    class-methods is_s4h
      returning
        value(r_yesno) type abap_bool.
    class-methods join
      importing
        it_tab type any table
        iv_fld type csequence optional
      returning
        value(rv_str) type string.
    class-methods read_dom_values
      importing
        !i_domain_name type dd01l-domname
        !i_langu type sy-langu default sy-langu
      returning
        value(rt_dd07v) type dd07v_tab.
    class-methods get_class_text_pool
      importing
        !i_obj type ref to object optional
        !i_class_name type seoclsname optional
        !i_langu type sy-langu default sy-langu
      returning
        value(r_texts) type table_of_textpool.


  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SBCGLIB_UTILS IMPLEMENTATION.


  method get_class_text_pool.

    data lo_obj_desc  type ref to cl_abap_objectdescr.
    data lv_class_inc type c length 32.
    data l_langu      type sy-langu.

    if i_langu is not initial.
      l_langu = i_langu.
    else.
      l_langu = sy-langu.
    endif.

    if i_obj is bound.
      lo_obj_desc ?= cl_abap_objectdescr=>describe_by_object_ref( i_obj ).
      lv_class_inc = lo_obj_desc->get_relative_name( ).
    elseif i_class_name is not initial.
      lv_class_inc = to_upper( i_class_name ).
    else.
      zcx_sbcglib_internal=>raise( |No class name or object passed as a param| ).
    endif.

    lv_class_inc+30(2) = 'CP'.
    translate lv_class_inc using ' ='.

    read textpool lv_class_inc into r_texts language l_langu.

  endmethod.


  method is_s4h.

    constants lc_method_name type string value 'IS_S4H'.

    data lo_cos_utils   type ref to cl_cos_utilities.
    data lo_refdescr    type ref to cl_abap_refdescr.
    data lo_classdescr  type ref to cl_abap_classdescr.

    lo_refdescr   ?= cl_abap_typedescr=>describe_by_data( lo_cos_utils ).
    lo_classdescr ?= lo_refdescr->get_referenced_type( ).

    read table lo_classdescr->methods transporting no fields
      with key name = lc_method_name.
    if sy-subrc = 0.
      call method cl_cos_utilities=>(lc_method_name)
        receiving
          rv_is_s4h = r_yesno.
    endif.

  endmethod.


  method join.

    data lv_row_type type c length 1.
    data lv_fld_type type c length 1.
    data lv_fld_name type string.
    data lv_tmp type string.
    field-symbols <row> type any.
    field-symbols <fld> type any.

    lv_fld_name = to_upper( |{ iv_fld }| ).

    loop at it_tab assigning <row>.
      if sy-tabix = 1.
        describe field <row> type lv_row_type.
      else.
        rv_str = rv_str && `, `.
      endif.

      if lv_row_type ca 'gC' and iv_fld is initial.
        rv_str = rv_str && |{ <row> }|.
      elseif lv_row_type ca 'uv' and iv_fld is not initial.
        assign component lv_fld_name of structure <row> to <fld>.
        if lv_fld_type is initial.
          zcx_sbcglib_internal=>assert_subrc( ). " First only is enough
          describe field <fld> type lv_fld_type.
        endif.
        if lv_fld_type ca 'gC'.
          rv_str = rv_str && |{ <fld> }|.
        elseif lv_fld_type = 'N'.
          lv_tmp = <fld>.
          shift lv_tmp left deleting leading '0'.
          rv_str = rv_str && lv_tmp.
        else.
          zcx_sbcglib_internal=>raise( |Unexpected fld type { lv_fld_type }| ).
        endif.
      else.
        zcx_sbcglib_internal=>raise( |Unexpected row type { lv_row_type }| ).
      endif.

    endloop.

  endmethod.


  method read_dom_values.

    data lt_dd07v_n type dd07v_tab.
    data l_langu    type sy-langu.

    if i_langu is not initial.
      l_langu = i_langu.
    else.
      l_langu = sy-langu.
    endif.

    call function 'DD_DOMA_GET'
      exporting
        domain_name   = i_domain_name
        langu         = l_langu
        prid          = 0
        withtext      = 'X'
      tables
        dd07v_tab_a   = rt_dd07v     "Domain fixed values in A version
        dd07v_tab_n   = lt_dd07v_n   "Domain fixed values in N version
      exceptions
        illegal_value = 1
        op_failure    = 2
        others        = 3.

    if sy-subrc <> 0.
      zcx_sbcglib_internal=>raise( |Cannot read domain { i_domain_name }| ).
    endif.

  endmethod.


  method uniq_list_of.

    field-symbols <i> type any.
    field-symbols <f> type any.

    if fld is initial.
      zcx_sbcglib_internal=>raise( 'UNIQ_LIST_OF: no field name supplied' ).
    endif.

    data lv_fld type abap_compname.
    lv_fld = to_upper( fld ).

    clear ev_result.
    loop at tab assigning <i>.
      assign component lv_fld of structure <i> to <f>.
      if sy-subrc is not initial.
        zcx_sbcglib_internal=>raise( |UNIQ_LIST_OF: no component with name { lv_fld }| ).
      endif.
      if <f> is not initial. " Non empty only !
        append <f> to ev_result.
      endif.
    endloop.

    sort ev_result.
    delete adjacent duplicates from ev_result.

  endmethod.
ENDCLASS.
