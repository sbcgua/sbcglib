class ZCX_SBCGLIB_ERROR definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  " SPDX-License-Identifier: Apache-2.0
  " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
  " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


  interfaces IF_T100_MESSAGE .

  types:
    ty_rc type c length 4 .

  constants:
    begin of ZCX_SBCGLIB_ERROR,
      msgid type symsgid value '00',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'V1',
      attr2 type scx_attrname value 'V2',
      attr3 type scx_attrname value 'V3',
      attr4 type scx_attrname value 'V4',
    end of ZCX_SBCGLIB_ERROR .
  data V1 type SYMSGV read-only .
  data V2 type SYMSGV read-only .
  data V3 type SYMSGV read-only .
  data V4 type SYMSGV read-only .
  data RC type TY_RC read-only .
  data LOCATION type STRING read-only .
  data MSG_TYPE type SYMSGTY read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !V1 type SYMSGV optional
      !V2 type SYMSGV optional
      !V3 type SYMSGV optional
      !V4 type SYMSGV optional
      !RC type TY_RC optional
      !LOCATION type STRING optional
      !MSG_TYPE type SYMSGTY optional .
  methods GET_BAPIRET2
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  class-methods RAISE_WITH_SY
    raising
      ZCX_SBCGLIB_ERROR .
  type-pools ABAP .
  class-methods RAISE_SIMPLE
    importing
      !MSG type CSEQUENCE
      !TYPE type SYMSGTY default 'E'
      !V1 type CLIKE optional
      !V2 type CLIKE optional
      !V3 type CLIKE optional
      !V4 type CLIKE optional
      !RC type TY_RC optional
      !W_LOC type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_SBCGLIB_ERROR .
  class-methods RAISE_W_MSG
    importing
      !MSGID type SYMSGID
      !MSGNO type SYMSGNO
      !V1 type CLIKE optional
      !V2 type CLIKE optional
      !V3 type CLIKE optional
      !V4 type CLIKE optional
      !TYPE type SYMSGTY default 'E'
    raising
      ZCX_SBCGLIB_ERROR .
  class-methods ASSERT_SUBRC
    importing
      !SUBRC type SY-SUBRC default SY-SUBRC
      !MSG type CSEQUENCE optional
    raising
      ZCX_SBCGLIB_ERROR .
  class-methods ASSERT_TRUE
    importing
      !TEST type ABAP_BOOL
      !MSG type CSEQUENCE optional
    raising
      ZCX_SBCGLIB_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SBCGLIB_ERROR IMPLEMENTATION.


method assert_subrc.

  if subrc <> 0.
    if msg is not initial.
      raise_simple(
        msg = msg
        w_loc = abap_true ).
    else.
      raise_simple(
        msg = 'subrc assertion failed'
        w_loc = abap_true ).
    endif.
  endif.

endmethod.


method assert_true.

  if test <> abap_true.
    if msg is not initial.
      raise_simple(
        msg = msg
        w_loc = abap_true ).
    else.
      raise_simple(
        msg = 'assertion failed'
        w_loc = abap_true ).
    endif.
  endif.

endmethod.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->V1 = V1 .
me->V2 = V2 .
me->V3 = V3 .
me->V4 = V4 .
me->RC = RC .
me->LOCATION = LOCATION .
me->MSG_TYPE = MSG_TYPE .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SBCGLIB_ERROR .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.


method get_bapiret2.

  rs_bapiret2-type       = me->msg_type.
  rs_bapiret2-id         = me->if_t100_message~t100key-msgid.
  rs_bapiret2-number     = me->if_t100_message~t100key-msgno.
  rs_bapiret2-message_v1 = me->if_t100_message~t100key-attr1.
  rs_bapiret2-message_v2 = me->if_t100_message~t100key-attr2.
  rs_bapiret2-message_v3 = me->if_t100_message~t100key-attr3.
  rs_bapiret2-message_v4 = me->if_t100_message~t100key-attr4.

endmethod.


method raise_simple.

  data l_prog type string.
  data l_meth type string.
  data l_location type string.
  data l_msg type string.
  data:
    begin of ls_split,
      v1 type symsgv,
      v2 type symsgv,
      v3 type symsgv,
      v4 type symsgv,
    end of ls_split.

  zcl_sbcglib_err_utils=>get_call_point(
    importing
      e_prog = l_prog
      e_meth = l_meth ).

  l_location = |{ l_prog }->{ l_meth }|.
  if w_loc = abap_true.
    l_msg = |{ l_location }: { msg }|.
  else.
    l_msg = msg.
  endif.
  ls_split   = zcl_sbcglib_err_utils=>format_message(
    msg = l_msg
    v1  = v1
    v2  = v2
    v3  = v3
    v4  = v4 ).

  raise exception type zcx_sbcglib_error
    exporting
      textid = zcx_sbcglib_error
      v1 = |{ ls_split-v1 }|
      v2 = |{ ls_split-v2 }|
      v3 = |{ ls_split-v3 }|
      v4 = |{ ls_split-v4 }|
      location = l_location
      msg_type = type
      rc = rc.

endmethod.


method raise_with_sy.

  data msg like if_t100_message~t100key.

  msg-msgno = sy-msgno.
  msg-msgid = sy-msgid.
  msg-attr1 = 'V1'.
  msg-attr2 = 'V2'.
  msg-attr3 = 'V3'.
  msg-attr4 = 'V4'.

  raise exception type zcx_sbcglib_error
    exporting
      textid = msg
      v1 = |{ sy-msgv1 }|
      v2 = |{ sy-msgv2 }|
      v3 = |{ sy-msgv3 }|
      v4 = |{ sy-msgv4 }|.

endmethod.


method raise_w_msg.

  data msg like if_t100_message~t100key.

  msg-msgid = msgid.
  msg-msgno = msgno.
  msg-attr1 = 'V1'.
  msg-attr2 = 'V2'.
  msg-attr3 = 'V3'.
  msg-attr4 = 'V4'.

  raise exception type zcx_sbcglib_error
    exporting
      textid = msg
      msg_type = type
      v1 = |{ v1 }|
      v2 = |{ v2 }|
      v3 = |{ v3 }|
      v4 = |{ v4 }|.

endmethod.
ENDCLASS.
