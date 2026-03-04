class zcl_sbcglib_log_view definition
  public
  final
  create private.

  public section.

    interfaces zif_sbcglib_view_callbacks.

    constants:
      begin of c_exit_command,
          close type char1 value '',
        end of c_exit_command.

    class-methods display
      importing
        !ii_log type ref to zif_sbcglib_log
        !iv_title type string optional
      returning
        value(rv_exit_command) type char1.

    methods constructor
      importing
        !iv_title type string.

  protected section.
  private section.
    types:
      begin of ty_log,
        icon     type icon-id,
        msgty    type zif_sbcglib_log=>ty_message-msgty,
        msgid    type zif_sbcglib_log=>ty_message-msgid,
        msgno    type zif_sbcglib_log=>ty_message-msgno,
        index    type zif_sbcglib_log=>ty_message-index,
        msg_text type c length 100, " ?
      end of ty_log.

    types tt_log_list type standard table of ty_log
      with key msgty msgid msgno.

    data mv_title type string.

    class-methods convert_log_table
      importing
        ii_log type ref to zif_sbcglib_log
      returning
        value(rt_log_list) type tt_log_list.

    class-methods get_fields_to_hide
      importing
        it_log_table type tt_log_list
        iv_default_msgid type symsgid
      returning
        value(rt_hidden_fields) type string_table.

    class-methods get_icon
      importing
        is_msg type zif_sbcglib_log=>ty_message
      returning
        value(rv_icon) type icon-id.

    methods _display
      importing
        !ii_log type ref to zif_sbcglib_log
      returning
        value(rv_exit_command) type char1.

ENDCLASS.



CLASS ZCL_SBCGLIB_LOG_VIEW IMPLEMENTATION.


  method constructor.

    if iv_title is initial.
      mv_title = 'Log'(002).
    else.
      mv_title = iv_title.
    endif.

  endmethod.


  method convert_log_table.

    data ls_line like line of rt_log_list.
    data lv_text type string.
    field-symbols <m> like line of ii_log->messages.

    loop at ii_log->messages assigning <m>.

*      call function 'MESSAGE_TEXT_BUILD'
*        exporting
*          msgid                = <m>-msgid
*          msgnr                = <m>-msgno
*          msgv1                = <m>-msgv1
*          msgv2                = <m>-msgv2
*          msgv3                = <m>-msgv3
*          msgv4                = <m>-msgv4
*        importing
*          message_text_output  = lv_text.

      message id <m>-msgid type 'I' number <m>-msgno into lv_text
        with <m>-msgv1 <m>-msgv2 <m>-msgv3 <m>-msgv4.

      move-corresponding <m> to ls_line.
      ls_line-icon     = get_icon( <m> ).
      ls_line-msg_text = lv_text.

      append ls_line to rt_log_list.

    endloop.

  endmethod.


  method display.

    data lo_log_view type ref to zcl_sbcglib_log_view.
    data lv_title type string.
    data lx type ref to cx_root.

    if lines( ii_log->messages ) = 0.
      message 'Log is empty'(001) type 'S'.
      return.
    endif.

    lv_title = iv_title.
    if lv_title is initial.
      lv_title = ii_log->name.
    endif.
    create object lo_log_view exporting iv_title = lv_title.

    try.
      rv_exit_command = lo_log_view->_display( ii_log ).
    catch cx_root into lx.
      message lx type 'E'.
    endtry.

  endmethod.


  method get_fields_to_hide.

    data lv_external_msgid_found type abap_bool.
    data lv_index_found type abap_bool.
    field-symbols <m> like line of it_log_table.

    append 'msgty' to rt_hidden_fields. " Because of icon

    loop at it_log_table assigning <m>.

      if <m>-msgid <> iv_default_msgid.
        lv_external_msgid_found = abap_true.
      endif.

      if <m>-index is not initial.
        lv_index_found = abap_true.
      endif.

    endloop.

    if lv_external_msgid_found = abap_false.
      append 'msgid' to rt_hidden_fields.
    endif.

    if lv_index_found = abap_false.
      append 'index' to rt_hidden_fields.
    endif.

  endmethod.


  method get_icon.

*    if is_msg-is_suppressed = abap_true.
*      rv_icon = icon_no_status.

    if is_msg-msgty = 'E'.
      rv_icon = icon_led_red.
    elseif is_msg-msgty = 'W'.
      rv_icon = icon_led_yellow.
    elseif is_msg-msgty = 'I'.
      rv_icon = icon_led_inactive.
    elseif is_msg-msgty = 'S'.
      rv_icon = icon_led_green.
    else.
      rv_icon = ''.
    endif.

  endmethod.


  method zif_sbcglib_view_callbacks~on_double_click.
  endmethod.


  method zif_sbcglib_view_callbacks~on_user_command.
  endmethod.


  method zif_sbcglib_view_callbacks~setup_columns.

    data lo_col type ref to cl_salv_column.
    data lv_icon_name type string.

    lv_icon_name = repeat( val = cl_abap_conv_in_ce=>uccp( '00A0' ) occ = 6 ). " Non-breakable space (overkill?)

    lo_col = io_columns->get_column( 'ICON' ).
    lo_col->set_alignment( if_salv_c_alignment=>centered ).
    lo_col->set_short_text( |{ lv_icon_name }| ).
    lo_col->set_medium_text( |{ lv_icon_name }| ).
*    lo_col->set_output_length( 20 ). does not work

    lo_col = io_columns->get_column( 'MSG_TEXT' ).
    lo_col->set_short_text( |{ 'Message'(003) }| ).
    lo_col->set_medium_text( |{ 'Message'(003) }| ).

    lo_col = io_columns->get_column( 'INDEX' ).
    lo_col->set_short_text( |{ '#' }| ).
    lo_col->set_medium_text( |{ '#' }| ).

  endmethod.


  method _display.

    data lt_log_list type tt_log_list.
    lt_log_list = convert_log_table( ii_log ).

    zcl_sbcglib_view=>create_popup(
      it_content   = lt_log_list
      iv_title     = mv_title
      ii_callbacks = me
      iv_popup_width  = 100
      iv_popup_height = 25
*      iv_pfstatus = '..._UNBOUND_DIALOGS/LOG_VIEW_DIALOG' " TODO !
      )->hide_fields( get_fields_to_hide(
        it_log_table = lt_log_list
        iv_default_msgid = ii_log->default_msgid( ) )
      )->display( ).

    rv_exit_command = c_exit_command-close.

  endmethod.
ENDCLASS.
