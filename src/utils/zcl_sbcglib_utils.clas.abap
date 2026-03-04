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

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SBCGLIB_UTILS IMPLEMENTATION.


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
