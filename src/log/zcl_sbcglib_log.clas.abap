class zcl_sbcglib_log definition
  public
  final
  create public.

  public section.

    " SPDX-License-Identifier: Apache-2.0
    " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
    " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


    interfaces zif_sbcglib_log.

    class-methods new
      importing
        i_msgid type symsgid optional
        i_name type string optional
      returning
        value(ro_instance) type ref to zcl_sbcglib_log.

    methods constructor
      importing
        i_msgid type symsgid optional
        i_name type string optional.

  protected section.
  private section.

    aliases messages for zif_sbcglib_log~messages.
    aliases addm for zif_sbcglib_log~addm.

    constants c_free_text_msgid type symsgid value '00'.
    constants c_free_text_msgno type symsgno value '001'.

    data mv_default_msgid type msgid.

    class-methods severity2msgty
      importing
        iv_severity type zif_sbcglib_log=>ty_severity
      returning
        value(r_msgty) type zif_sbcglib_log=>ty_message-msgty.

    class-methods format_message
      importing
        i_rec type zif_sbcglib_log=>ty_message
      returning
        value(rv_str) type string.

ENDCLASS.



CLASS ZCL_SBCGLIB_LOG IMPLEMENTATION.


  method constructor.

    mv_default_msgid = i_msgid.
    zif_sbcglib_log~name = i_name.

  endmethod.


  method format_message.

    if i_rec is not initial.
      message
        id i_rec-msgid type i_rec-msgty number i_rec-msgno
        into rv_str
        with i_rec-msgv1 i_rec-msgv2 i_rec-msgv3 i_rec-msgv4.
    endif.

  endmethod.


  method new.

    create object ro_instance
      exporting
        i_msgid = i_msgid
        i_name  = i_name.

  endmethod.


  method severity2msgty.

    case iv_severity.
      when zif_sbcglib_log=>c_severity-error.
        r_msgty = 'E'.
      when zif_sbcglib_log=>c_severity-warning.
        r_msgty = 'W'.
      when zif_sbcglib_log=>c_severity-info or zif_sbcglib_log=>c_severity-none.
        r_msgty = 'I'.
      when others.
        " error ?
    endcase.

  endmethod.


  method zif_sbcglib_log~addm.

    data ls_msg_log like line of messages.

    ls_msg_log-msgid = id.
    ls_msg_log-msgty = ty.
    ls_msg_log-msgno = no.
    ls_msg_log-msgv1 = v1.
    ls_msg_log-msgv2 = v2.
    ls_msg_log-msgv3 = v3.
    ls_msg_log-msgv4 = v4.
    ls_msg_log-index = index.

    if ls_msg_log-msgid is initial.
      ls_msg_log-msgid = mv_default_msgid.
    endif.

    if first is initial.
      append ls_msg_log to messages.
    else.
      insert ls_msg_log into messages index 1.
    endif.

  endmethod.


  method zif_sbcglib_log~addx.

    zif_sbcglib_log~add_str(
      ty = ty
      msg = ex->get_text( ) ).

  endmethod.


  method zif_sbcglib_log~add_bdcmsgcoll.

    addm(
      id = i_bdcmsgcoll-msgid
      ty = i_bdcmsgcoll-msgtyp
      no = |{ i_bdcmsgcoll-msgnr }|
      v1 = i_bdcmsgcoll-msgv1
      v2 = i_bdcmsgcoll-msgv2
      v3 = i_bdcmsgcoll-msgv3
      v4 = i_bdcmsgcoll-msgv4 ).

  endmethod.


  method zif_sbcglib_log~add_if_t100_msg.

    cl_message_helper=>set_msg_vars_for_if_t100_msg( ex ).

    addm(
      ty = ty
      id = sy-msgid
      no = sy-msgno
      v1 = sy-msgv1
      v2 = sy-msgv2
      v3 = sy-msgv3
      v4 = sy-msgv4
      first = first ).

  endmethod.


  method zif_sbcglib_log~add_rec.

    addm(
      id = is_rec-msgid
      ty = is_rec-msgty
      no = is_rec-msgno
      v1 = is_rec-msgv1
      v2 = is_rec-msgv2
      v3 = is_rec-msgv3
      v4 = is_rec-msgv4 ).

  endmethod.


  method zif_sbcglib_log~add_str.

    data:
      lv_char_msg type c length 200,
      begin of ls_v,
        v1 type symsgv,
        v2 type symsgv,
        v3 type symsgv,
        v4 type symsgv,
      end of ls_v.

    lv_char_msg = msg.
    ls_v = lv_char_msg.

    addm(
      ty = ty
      id = c_free_text_msgid
      no = c_free_text_msgno
      index = index
      v1 = ls_v-v1
      v2 = ls_v-v2
      v3 = ls_v-v3
      v4 = ls_v-v4 ).

  endmethod.


  method zif_sbcglib_log~add_sy.

    addm(
      id = i_sy-msgid
      ty = i_sy-msgty
      no = i_sy-msgno
      v1 = i_sy-msgv1
      v2 = i_sy-msgv2
      v3 = i_sy-msgv3
      v4 = i_sy-msgv4 ).

  endmethod.                                             "#EC CI_VALPAR


  method zif_sbcglib_log~clear.
    clear messages.
  endmethod.


  method zif_sbcglib_log~default_msgid.
    rv_msgid = mv_default_msgid.
  endmethod.


  method zif_sbcglib_log~e.
    addm( id = id ty = 'E' no = no v1 = v1 v2 = v2 v3 = v3 v4 = v4 index = index ).
  endmethod.


  method zif_sbcglib_log~get_bapiret_tab.

    field-symbols <l> like line of messages.
    field-symbols <bapiret> like line of rt_bapiret.

    loop at messages assigning <l>.
      append initial line to rt_bapiret assigning <bapiret>.
      <bapiret>-type       = <l>-msgty.
      <bapiret>-id         = <l>-msgid.
      <bapiret>-number     = <l>-msgno.
      <bapiret>-message_v1 = <l>-msgv1.
      <bapiret>-message_v2 = <l>-msgv2.
      <bapiret>-message_v3 = <l>-msgv3.
      <bapiret>-message_v4 = <l>-msgv4.
    endloop.

  endmethod.


  method zif_sbcglib_log~get_first_message.
    read table messages into rs_message index 1.
  endmethod.


  method zif_sbcglib_log~get_first_message_text.

    data ls_message like line of messages.
    ls_message = zif_sbcglib_log~get_first_message( ).
    rv_message = format_message( ls_message ).

  endmethod.


  method zif_sbcglib_log~has_errors.
    read table messages transporting no fields with key msgty = 'E'.
    r_yesno = boolc( sy-subrc = 0 ).
  endmethod.


  method zif_sbcglib_log~has_msg_no.
    read table messages with key msgid = id msgno = no transporting no fields.
    r_yesno = boolc( sy-subrc = 0 ).
  endmethod.


  method zif_sbcglib_log~has_warnings.
    read table messages transporting no fields with key msgty = 'W'.
    r_yesno = boolc( sy-subrc = 0 ).
  endmethod.


  method zif_sbcglib_log~is_empty.
    rv_yes = boolc( lines( messages ) > 0 ).
  endmethod.


  method zif_sbcglib_log~log_highest_msg_type.

    field-symbols <msg> like line of messages.
    rv_highest_msg_type = 'I'.

    loop at messages assigning <msg>.
      case <msg>-msgty.
        when 'E' or 'X'.
          rv_highest_msg_type = 'E'.
          exit.
        when 'W'.
          rv_highest_msg_type = 'W'.
        when 'S' or 'I'.
          " nothing to change - info is the default above
        when others.
          " error ?
      endcase.
    endloop.

  endmethod.


  method zif_sbcglib_log~log_severity.

    field-symbols <msg> like line of messages.

    loop at messages assigning <msg>.
      case <msg>-msgty.
        when 'E' or 'X'.
          rv_severity = zif_sbcglib_log=>c_severity-error.
          exit.
        when 'W'.
          rv_severity = zif_sbcglib_log=>c_severity-warning.
        when 'S' or 'I'.
          if rv_severity < zif_sbcglib_log=>c_severity-info.
            rv_severity = zif_sbcglib_log=>c_severity-info.
          endif.
        when others.
          " error ?
      endcase.
    endloop.

  endmethod.


  method zif_sbcglib_log~merge_with.

    data ls_item like line of messages.

    if ii_log is bound.
      loop at ii_log->messages into ls_item.
        if set_severity is supplied.
          ls_item-msgty = severity2msgty( set_severity ).
        endif.
        append ls_item to messages.
      endloop.
    endif.

  endmethod.


  method zif_sbcglib_log~s.
    addm( id = id ty = 'S' no = no v1 = v1 v2 = v2 v3 = v3 v4 = v4 index = index ).
  endmethod.


  method zif_sbcglib_log~set_severity.

    field-symbols <msg> like line of messages.

    loop at messages assigning <msg>.
      <msg>-msgty = severity2msgty( iv_severity ).
    endloop.

  endmethod.


  method zif_sbcglib_log~size.
    rv_size = lines( messages ).
  endmethod.


  method zif_sbcglib_log~w.
    addm( id = id ty = 'W' no = no v1 = v1 v2 = v2 v3 = v3 v4 = v4 index = index ).
  endmethod.
ENDCLASS.
