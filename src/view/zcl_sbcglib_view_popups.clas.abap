class zcl_sbcglib_view_popups definition
  public
  final
  create public.

  public section.

    class-methods popup_to_confirm
      importing
        !iv_title          type csequence
        !iv_text           type csequence
        !iv_btn_text1      type text132 optional
        !iv_btn_text2      type text132 optional
        !iv_btn_icon1      type icon-name optional
        !iv_btn_icon2      type icon-name optional
        !iv_btn_info1      type text132 optional
        !iv_btn_info2      type text132 optional
        !iv_default_btn    type char1 default '1'
        !iv_display_cancel type abap_bool default abap_true
        !iv_popup_type     type icon-name optional
      returning
        value(rv_result) type char1.

    class-methods popup_to_confirm_with_message
      importing
        !iv_default_opt    type char1 optional
        !iv_diagnose_text1 type csequence
        !iv_diagnose_text2 type csequence optional
        !iv_diagnose_text3 type csequence optional
        !iv_textline1      type csequence
        !iv_textline2      type csequence optional
        !iv_title          type csequence
        !iv_start_column   type i optional
        !iv_start_row      type i optional
        !iv_display_cancel type abap_bool optional
      returning
        value(rv_result) type char1.

    class-methods popup_to_select
      importing
        !iv_title    type char40
        !it_fieldcat type slis_t_fieldcat_alv
        !it_data     type standard table
      returning
        value(rv_index) type i.

    class-methods popup_get_values
      importing
        !iv_title type csequence
      exporting
        value(ev_code) type char1
      changing
        !ct_fields type uxp_t_popup_field.

    class-methods popup_get_one_value
      importing
        !iv_title   type csequence
        !iv_field   type string
        !iv_default type sval-value
      returning
        value(rv_value) type sval-value.

  protected section.
  private section.

ENDCLASS.



CLASS ZCL_SBCGLIB_VIEW_POPUPS IMPLEMENTATION.


  method popup_get_one_value.

    data lt_fields type uxp_t_popup_field.
    data ls_field  like line of lt_fields.
    data l_return  type c.

    split iv_field at '-' into ls_field-tabname ls_field-fieldname.
    ls_field-tabname   = to_upper( ls_field-tabname ).
    ls_field-fieldname = to_upper( ls_field-fieldname ).
    ls_field-value     = iv_default.
    append ls_field to lt_fields.

    popup_get_values(
      exporting
        iv_title = iv_title
      importing
        ev_code  = l_return
      changing
        ct_fields = lt_fields ).

    if lt_fields is initial.
      return. " TODO ???
    endif.

    read table lt_fields into ls_field index 1.
    rv_value = ls_field-value.

  endmethod.


  method popup_get_values.

    data lv_title type c length 40.

    lv_title = iv_title.

    call function 'POPUP_GET_VALUES'
      exporting
        no_value_check  = ' '
        popup_title     = lv_title
        start_column    = '5'
        start_row       = '3'
      importing
        returncode      = ev_code
      tables
        fields          = ct_fields
      exceptions
        error_in_fields = 1
        others          = 2.

    " Valid answers: empty (value entered) , A (user input cancelled)
    if sy-subrc <> 0.
      clear ct_fields.
      zcx_sbcglib_view_error=>raise( 'Error calling POPUP_GET_VALUES' ).
    endif.

  endmethod.


  method popup_to_confirm.

    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar              = iv_title
        text_question         = iv_text
        text_button_1         = iv_btn_text1
        icon_button_1         = iv_btn_icon1
        iv_quickinfo_button_1 = iv_btn_info1
        text_button_2         = iv_btn_text2
        icon_button_2         = iv_btn_icon2
        iv_quickinfo_button_2 = iv_btn_info2
        default_button        = iv_default_btn
        display_cancel_button = iv_display_cancel
        start_column          = 10
        start_row             = 6
        popup_type            = iv_popup_type
      importing
        answer                = rv_result
      exceptions
        text_not_found        = 1
        others                = 2.

    " Valid answers: 1, 2, A (cancel)
    if sy-subrc <> 0.
      zcx_sbcglib_view_error=>raise( 'Error calling POPUP_TO_CONFIRM' ).
    endif.

  endmethod.


  method popup_to_confirm_with_message.

    call function 'POPUP_TO_CONFIRM_WITH_MESSAGE'
      exporting
        defaultoption  = iv_default_opt
        diagnosetext1  = iv_diagnose_text1
        diagnosetext2  = iv_diagnose_text2
        diagnosetext3  = iv_diagnose_text3
        textline1      = iv_textline1
        textline2      = iv_textline2
        titel          = iv_title
        start_column   = iv_start_column
        start_row      = iv_start_row
        cancel_display = iv_display_cancel
      importing
        answer         = rv_result.

  endmethod.


  method popup_to_select.

    data lv_exit      type char1.
    data ls_selfield  type slis_selfield.
    data lt_excluding type slis_t_extab.

    field-symbols <b> like line of lt_excluding.

    define _exclude_button.
      append initial line to lt_excluding assigning <b>.
      <b>-fcode = &1.
    end-of-definition.

    " Exclude buttons
    _exclude_button '&ETA'.
    _exclude_button '%SC'.
    _exclude_button '%SC+'.
    _exclude_button '&ILT'.
    _exclude_button '&OUP'.
    _exclude_button '&ODN'.
    _exclude_button '&OL0'.

    call function 'REUSE_ALV_POPUP_TO_SELECT'
      exporting
        i_title               = iv_title
        i_zebra               = ''
        i_screen_start_column = 5
        i_screen_start_line   = 3
        i_tabname             = '1'
        it_fieldcat           = it_fieldcat
        it_excluding          = lt_excluding
      importing
        es_selfield           = ls_selfield
        e_exit                = lv_exit
      tables
        t_outtab              = it_data
      exceptions
        program_error         = 1
        others                = 2.

    if sy-subrc <> 0.
      zcx_sbcglib_view_error=>raise( 'Error in REUSE_ALV_POPUP_TO_SELECT' ).
    endif.
    if lv_exit = 'X'.
      return.
    endif.
    rv_index = ls_selfield-tabindex.

  endmethod.
ENDCLASS.
