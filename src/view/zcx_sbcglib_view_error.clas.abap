class ZCX_SBCGLIB_VIEW_ERROR definition
  public
  inheriting from CX_NO_CHECK
  final
  create public .

public section.

  " SPDX-License-Identifier: Apache-2.0
  " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
  " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SBCGLIB_VIEW_ERROR,
      msgid type symsgid value '00',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'V1',
      attr2 type scx_attrname value 'V2',
      attr3 type scx_attrname value 'V3',
      attr4 type scx_attrname value 'V4',
    end of ZCX_SBCGLIB_VIEW_ERROR .
  data V1 type SYMSGV read-only .
  data V2 type SYMSGV read-only .
  data V3 type SYMSGV read-only .
  data V4 type SYMSGV read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !V1 type SYMSGV optional
      !V2 type SYMSGV optional
      !V3 type SYMSGV optional
      !V4 type SYMSGV optional .
  class-methods RAISE
    importing
      !M type CSEQUENCE .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SBCGLIB_VIEW_ERROR IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->V1 = V1 .
me->V2 = V2 .
me->V3 = V3 .
me->V4 = V4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SBCGLIB_VIEW_ERROR .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.


method raise.

  data:
    begin of ls_split,
      v1 like v1,
      v2 like v1,
      v3 like v1,
      v4 like v1,
    end of ls_split.

  ls_split = m.

  raise exception type zcx_sbcglib_view_error
    exporting
      v1 = ls_split-v1
      v2 = ls_split-v2
      v3 = ls_split-v3
      v4 = ls_split-v4.

endmethod.
ENDCLASS.
