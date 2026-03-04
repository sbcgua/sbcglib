class ZCL_SBCGLIB_DRILLDOWN definition
  public
  final
  create public.

  public section.

    " SPDX-License-Identifier: Apache-2.0
    " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
    " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


    types:
      tty_bdcmsgcoll type standard table of bdcmsgcoll with default key.

    class-methods to_bp
      importing
        !iv_bp_number type bu_partner
      raising
        zcx_sbcglib_error.
    class-methods to_business_partner
      importing
        !i_bukrs type bukrs
        !i_kunnr type kunnr optional
        !i_lifnr type lifnr optional
      raising
        zcx_sbcglib_error.
    class-methods to_fi_document
      importing
        !i_bukrs type bukrs
        !i_belnr type belnr_d
        !i_gjahr type gjahr
      raising
        zcx_sbcglib_error.
    class-methods to_sd_contract
      importing
        !i_vbeln type vbeln
      raising
        zcx_sbcglib_error.
    class-methods to_sd_order
      importing
        !i_vbeln type vbeln
      raising
        zcx_sbcglib_error.
    class-methods to_sd_delivery
      importing
        !i_vbeln type vbeln
      raising
        zcx_sbcglib_error.
    class-methods to_sd_document
      importing
        !i_vbeln type vbeln
      raising
        zcx_sbcglib_error.
    class-methods to_sd_rebate
      importing
        !i_knuma type knuma
      raising
        zcx_sbcglib_error.
    class-methods to_mm_contract
      importing
        !i_ebeln type knuma
      raising
        zcx_sbcglib_error.
    class-methods to_mm_order
      importing
        !i_ebeln type knuma
      raising
        zcx_sbcglib_error.
    class-methods to_material
      importing
        !i_matnr type matnr
      raising
        zcx_sbcglib_error.
    class-methods call_transaction_w_auth_check
      importing
        !i_tcode type clike
        !it_using type bdcdata_tab
        !i_mode type c default ''
        !i_skip_first_screen type abap_bool default abap_false
        !is_options type ctu_params optional
      returning
        value(rt_messages) type tty_bdcmsgcoll
      raising
        zcx_sbcglib_error.
    class-methods set_memory_parameters
      importing
        !it_parameters type bdcdata_tab.

  protected section.
  private section.

    class-methods is_business_partner
      importing
        !iv_kunnr type kunnr optional
        !iv_lifnr type lifnr optional
      returning
        value(rv_bp_partner) type bu_partner.

ENDCLASS.



CLASS ZCL_SBCGLIB_DRILLDOWN IMPLEMENTATION.


  method call_transaction_w_auth_check.

    if i_tcode is initial.
      zcx_sbcglib_error=>raise_simple( 'call_transaction_w_auth_check: Empty TCODE' ).
    endif.

    if i_skip_first_screen = abap_true and ( i_mode is not initial or is_options is not initial ).
      zcx_sbcglib_error=>raise_simple( 'Incorrect combination of MODE/SKIP_1ST_SCREEN' ).
    endif.

    zcl_sbcglib_auth_utils=>auth_check_tcode( i_tcode ).

    if i_skip_first_screen = abap_true.
      set_memory_parameters( it_using ).
      call transaction i_tcode and skip first screen. "#EC CI_CALLTA
    elseif i_mode is not initial.
      call transaction i_tcode
        using it_using
        mode  i_mode
        messages into rt_messages. "#EC CI_CALLTA
    elseif is_options is not initial.
      call transaction i_tcode
        using it_using
        options from is_options
        messages into rt_messages. "#EC CI_CALLTA
    else.
      zcx_sbcglib_error=>raise_simple( 'skip_1st_screen or mode or options must be specified' ).
    endif.

  endmethod.


  method is_business_partner.

    if iv_kunnr is not initial.
      select single partner
        from but000 as b
          inner join cvi_cust_link as c
          on  c~customer     = iv_kunnr
          and c~partner_guid = b~partner_guid
        into rv_bp_partner.
    endif.

    if iv_lifnr is not initial.
      select single partner
        from but000 as b
          inner join cvi_vend_link as c
          on  c~vendor       = iv_lifnr
          and c~partner_guid = b~partner_guid
        into rv_bp_partner.
    endif.

  endmethod.


  method set_memory_parameters.

    field-symbols <p> like line of it_parameters.
    data lv_memid type memoryid.

    loop at it_parameters assigning <p>.
      lv_memid = <p>-fnam.
      if <p>-fval is initial.
        set parameter id lv_memid field space.
      else.
        set parameter id lv_memid field <p>-fval.
      endif.
    endloop.

  endmethod.


  method to_bp.

    data lo_request  type ref to cl_bupa_navigation_request.
    data lv_activity type bu_aktyp value '03'. " 01 - Create, 02 - Change, 03 - Display

    if iv_bp_number is initial.
      return.
    endif.

    create object lo_request.

    lo_request->set_partner_number( iv_bp_number ).
    lo_request->set_bupa_activity( lv_activity ).

    cl_bupa_dialog_joel=>start_with_navigation(
       exporting
         iv_request              = lo_request
       exceptions
         already_started         = 1
         not_allowed             = 2
         others                  = 3 ).

    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( 'Error occured while navigation to BP' ).
    endif.

  endmethod.


  method to_business_partner.

    data lv_bp_partner type bu_partner.
    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_lifnr is initial and i_kunnr is initial.
      return.
    endif.

    lv_bp_partner = is_business_partner(
      iv_kunnr = i_kunnr
      iv_lifnr = i_lifnr ).
    if lv_bp_partner is not initial.
      to_bp( lv_bp_partner ).
      return.
    endif.

    if i_lifnr is not initial.
      append initial line to lt_using assigning <u>.
      <u>-program  = 'SAPMF02K'.
      <u>-dynpro   = '0106'.
      <u>-dynbegin = 'X'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'BDC_OKCODE'.
      <u>-fval = '/00'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02K-BUKRS'.
      <u>-fval = i_bukrs.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02K-LIFNR'.
      <u>-fval = i_lifnr.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02K-D0110'.
      <u>-fval = 'X'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02K-D0120'.
      <u>-fval = 'X'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02K-D0130'.
      <u>-fval = 'X'.

      call_transaction_w_auth_check(
        i_tcode  = 'FK03'
        i_mode   = 'E'
        it_using = lt_using ).

    elseif i_kunnr is not initial.
      append initial line to lt_using assigning <u>.
      <u>-program  = 'SAPMF02D'.
      <u>-dynpro   = '0106'.
      <u>-dynbegin = 'X'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'BDC_OKCODE'.
      <u>-fval = '/00'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02D-BUKRS'.
      <u>-fval = i_bukrs.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02D-KUNNR'.
      <u>-fval = i_kunnr.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02D-D0110'.
      <u>-fval = 'X'.
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'RF02D-D0120'.
      <u>-fval = 'X'.

      call_transaction_w_auth_check(
        i_tcode  = 'FD03'
        i_mode   = 'E'
        it_using = lt_using ).

    endif.

  endmethod.


  method to_fi_document.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'BUK'.
    <u>-fval = i_bukrs.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'BLN'.
    <u>-fval = i_belnr.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'GJR'.
    <u>-fval = i_gjahr.

    call_transaction_w_auth_check(
      i_tcode             = 'FB03'
      i_skip_first_screen = abap_true
      it_using            = lt_using ).

  endmethod.


  method to_material.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_matnr is initial.
      return.
    endif.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'MAT'.
    <u>-fval = i_matnr.
    append initial line to lt_using assigning <u>.
    <u>-fnam = 'MXX'.
    <u>-fval = 'K'.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'MM03'
      it_using            = lt_using ).

  endmethod.


  method to_mm_contract.

    data lv_bstyp type ekko-bstyp.
    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_ebeln is initial.
      return.
    endif.

    " Check contract type
    select single bstyp into lv_bstyp
      from ekko
      where ebeln = i_ebeln.

    if lv_bstyp = 'K'.        " Contract
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'CTR'.
      <u>-fval = i_ebeln.
      call_transaction_w_auth_check(
        i_skip_first_screen = abap_true
        i_tcode             = 'ME33K'
        it_using            = lt_using ).
    elseif lv_bstyp = 'L'.    " Scheduling agreement
      append initial line to lt_using assigning <u>.
      <u>-fnam = 'SAG'.
      <u>-fval = i_ebeln.
      call_transaction_w_auth_check(
        i_skip_first_screen = abap_true
        i_tcode             = 'ME33L'
        it_using            = lt_using ).
    endif.

  endmethod.


  method to_mm_order.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'BES'.
    <u>-fval = i_ebeln.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'ME23N'
      it_using            = lt_using ).

  endmethod.


  method to_sd_contract.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_vbeln is initial.
      return.
    endif.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'KTN'.
    <u>-fval = i_vbeln.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'VA43'
      it_using            = lt_using ).

  endmethod.


  method to_sd_delivery.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_vbeln is initial.
      return.
    endif.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'VL'.
    <u>-fval = i_vbeln.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'VL03N'
      it_using            = lt_using ).

  endmethod.


  method to_sd_document.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_vbeln is initial.
      return.
    endif.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'VF'.
    <u>-fval = i_vbeln.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'VF03'
      it_using            = lt_using ).

  endmethod.


  method to_sd_order.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'AUN'.
    <u>-fval = i_vbeln.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'VA03'
      it_using            = lt_using ).

  endmethod.


  method to_sd_rebate.

    data lt_using type table of bdcdata.
    field-symbols <u> like line of lt_using.

    if i_knuma is initial.
      return.
    endif.

    append initial line to lt_using assigning <u>.
    <u>-fnam = 'VBO'.
    <u>-fval = i_knuma.

    call_transaction_w_auth_check(
      i_skip_first_screen = abap_true
      i_tcode             = 'VBO3'
      it_using            = lt_using ).

  endmethod.
ENDCLASS.
