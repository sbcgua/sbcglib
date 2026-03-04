interface zif_sbcglib_log
  public.

  " SPDX-License-Identifier: Apache-2.0
  " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
  " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib

  " TYPES

  types:
    begin of ty_message,
      msgid type symsgid,
      msgno type symsgno,
      msgty type symsgty,
      msgv1 type symsgv,
      msgv2 type symsgv,
      msgv3 type symsgv,
      msgv4 type symsgv,
      index type i,
    end of ty_message.
  types:
    tt_messages type standard table of ty_message with key msgid msgno.

  types ty_severity type i.

  constants:
    begin of c_type,
      info type msgty value 'I',
      success type msgty value 'S',
      warning type msgty value 'W',
      error type msgty value 'E',
      crtical type msgty value 'X',
    end of c_type.

  constants:
    begin of c_severity,
      none    type ty_severity value 0,
      info    type ty_severity value 1,
      warning type ty_severity value 2,
      error   type ty_severity value 3,
    end of c_severity.

  data messages type tt_messages read-only.
  data name type string read-only.

  " ADDING MESSAGES

  methods addm
    importing
      id type symsgid optional
      ty type symsgty
      no type symsgno
      v1 type clike optional
      v2 type clike optional
      v3 type clike optional
      v4 type clike optional
      index type i optional
      first type abap_bool default abap_false.

  methods add_rec
    importing
      is_rec type ty_message.

  methods add_str
    importing
      msg type string
      index type i optional
      ty type symsgty default 'E'.

  methods addx
    importing
      ex type ref to if_message
      ty type symsgty default 'E'.

  methods add_bdcmsgcoll
    importing
      i_bdcmsgcoll type bdcmsgcoll.

  methods add_sy
    importing
      value(i_sy) type syst default sy.

  methods add_if_t100_msg
    importing
      !ex type ref to if_t100_message
      !ty type symsgty default 'E'
      !first type abap_bool default abap_false.

  methods w
    importing
      !id type symsgid optional
      !no type symsgno
      !v1 type clike optional
      !v2 type clike optional
      !v3 type clike optional
      !v4 type clike optional
      index type i optional.
  methods e
    importing
      !id type symsgid optional
      !no type symsgno
      !v1 type clike optional
      !v2 type clike optional
      !v3 type clike optional
      !v4 type clike optional
      index type i optional.
  methods s
    importing
      !id type symsgid optional
      !no type symsgno
      !v1 type clike optional
      !v2 type clike optional
      !v3 type clike optional
      !v4 type clike optional
      index type i optional.

  " SELECTORS

  methods is_empty
    returning
      value(rv_yes) type abap_bool.

  methods has_warnings
    returning
      value(r_yesno) type abap_bool.

  methods has_errors
    returning
      value(r_yesno) type abap_bool.

  methods has_msg_no
    importing
      id type symsgid optional
      no type symsgno
    returning
      value(r_yesno) type abap_bool.

  methods size
    returning
      value(rv_size) type i.

  methods get_first_message
    returning
      value(rs_message) type ty_message.

  methods get_first_message_text
    returning
      value(rv_message) type string.

  methods get_bapiret_tab
    returning
      value(rt_bapiret) type bapirettab.

  methods log_severity
    returning
      value(rv_severity) type ty_severity.

  methods log_highest_msg_type
    returning
      value(rv_highest_msg_type) type symsgty.

  methods default_msgid
    returning
      value(rv_msgid) type symsgid.

  " MODIFIERS

  methods clear.

  methods merge_with
    importing
      ii_log type ref to zif_sbcglib_log
      set_severity type ty_severity optional.

  methods set_severity
    importing
      iv_severity type ty_severity.

endinterface.
