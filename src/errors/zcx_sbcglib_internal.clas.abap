class ZCX_SBCGLIB_INTERNAL definition
  public
  inheriting from CX_NO_CHECK
  final
  create public .

public section.
  type-pools ABAP .

  interfaces IF_T100_MESSAGE .

  types:
    ty_rc type c length 4 .

  constants:
    begin of ZCX_SBCGLIB_INTERNAL,
      msgid type symsgid value '00',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'V1',
      attr2 type scx_attrname value 'V2',
      attr3 type scx_attrname value 'V3',
      attr4 type scx_attrname value 'V4',
    end of ZCX_SBCGLIB_INTERNAL .
  data V1 type SYMSGV read-only .
  data V2 type SYMSGV read-only .
  data V3 type SYMSGV read-only .
  data V4 type SYMSGV read-only .
  data RC type TY_RC read-only .
  data LOCATION type STRING read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !V1 type SYMSGV optional
      !V2 type SYMSGV optional
      !V3 type SYMSGV optional
      !V4 type SYMSGV optional
      !RC type TY_RC optional
      !LOCATION type STRING optional .
  class-methods RAISE
    importing
      !MSG type CSEQUENCE
      !RC type TY_RC optional .
  methods GET_BAPIRET2
    returning
      value(RS_BAPIRET2) type BAPIRET2 .
  class-methods ASSERT_SUBRC
    importing
      !SUBRC type SY-SUBRC default SY-SUBRC
      !MSG type CSEQUENCE optional
    preferred parameter SUBRC .
  class-methods ASSERT_TRUE
    importing
      !TEST type ABAP_BOOL
      !MSG type CSEQUENCE optional
    preferred parameter TEST .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SBCGLIB_INTERNAL IMPLEMENTATION.


method assert_subrc.

  if subrc <> 0.
    if msg is not initial.
      raise( msg ).
    else.
      raise( 'subrc assertion failed' ).
    endif.
  endif.

endmethod.


method assert_true.

  if test <> abap_true.
    if msg is not initial.
      raise( msg ).
    else.
      raise( 'assertion failed' ).
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
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SBCGLIB_INTERNAL .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.


method get_bapiret2.

  rs_bapiret2-type       = 'E'.
  rs_bapiret2-id         = me->if_t100_message~t100key-msgid.
  rs_bapiret2-number     = me->if_t100_message~t100key-msgno.
  rs_bapiret2-message_v1 = me->if_t100_message~t100key-attr1.
  rs_bapiret2-message_v2 = me->if_t100_message~t100key-attr2.
  rs_bapiret2-message_v3 = me->if_t100_message~t100key-attr3.
  rs_bapiret2-message_v4 = me->if_t100_message~t100key-attr4.

endmethod.


method raise.

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
  l_msg      = |{ l_location }: { msg }|.
  ls_split   = l_msg.

  raise exception type zcx_sbcglib_internal
    exporting
      textid = zcx_sbcglib_internal
      v1 = |{ ls_split-v1 }|
      v2 = |{ ls_split-v2 }|
      v3 = |{ ls_split-v3 }|
      v4 = |{ ls_split-v4 }|
      location = l_location
      rc = rc.

endmethod.
ENDCLASS.
