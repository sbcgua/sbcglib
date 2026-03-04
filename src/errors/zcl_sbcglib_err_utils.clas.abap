class ZCL_SBCGLIB_ERR_UTILS definition
  public
  final
  create public.

  public section.

    " SPDX-License-Identifier: Apache-2.0
    " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
    " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib

    class-methods format_message
      importing
        !msg type csequence
        !v1 type clike optional
        !v2 type clike optional
        !v3 type clike optional
        !v4 type clike optional
      returning
        value(rv_formatted) type string.

    class-methods get_call_point
      importing
        !depth type i default 3
      exporting
        !e_prog type string
        !e_meth type string.

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SBCGLIB_ERR_UTILS IMPLEMENTATION.


  method format_message.

    rv_formatted = msg.
    if v1 is not initial.
      replace first occurrence of '&1' in rv_formatted with v1.
      if sy-subrc <> 0.
        replace first occurrence of '&' in rv_formatted with v1.
      endif.
    endif.
    if v2 is not initial.
      replace first occurrence of '&2' in rv_formatted with v2.
      if sy-subrc <> 0.
        replace first occurrence of '&' in rv_formatted with v2.
      endif.
    endif.
    if v3 is not initial.
      replace first occurrence of '&3' in rv_formatted with v3.
      if sy-subrc <> 0.
        replace first occurrence of '&' in rv_formatted with v3.
      endif.
    endif.
    if v4 is not initial.
      replace first occurrence of '&4' in rv_formatted with v4.
      if sy-subrc <> 0.
        replace first occurrence of '&' in rv_formatted with v4.
      endif.
    endif.

  endmethod.


  method get_call_point.

    data lt_sys_stack type sys_callst.
    data ls_sys_call  like line of lt_sys_stack.

    clear: e_prog, e_meth.
    assert depth > 0 and depth < 10.

    call function 'SYSTEM_CALLSTACK'
      exporting
        max_level    = depth
      importing
        et_callstack = lt_sys_stack.

    read table lt_sys_stack into ls_sys_call index depth.
    e_prog = ls_sys_call-progname.
    e_meth = ls_sys_call-eventname.

    if ls_sys_call-eventtype = 'METH'.
      data oref type ref to if_oo_class_incl_naming.
      data oclif type ref to if_oo_clif_incl_naming.

      "oref ?= cl_oo_include_naming=>get_instance_by_include( sys_call-progname ).

      call method cl_oo_include_naming=>get_instance_by_include
        exporting
          progname       = ls_sys_call-progname
        receiving
          cifref         = oclif
        exceptions
          no_objecttype  = 1
          internal_error = 2.
      if sy-subrc is initial.
        oref ?= oclif.
        e_prog = oref->clskey-clsname.
      endif.
    endif.

  endmethod.
ENDCLASS.
