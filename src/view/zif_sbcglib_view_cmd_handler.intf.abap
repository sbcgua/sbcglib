interface zif_sbcglib_view_cmd_handler
  public.

  " SPDX-License-Identifier: Apache-2.0
  " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
  " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib

  methods on_user_command
    importing
      !iv_cmd       type salv_de_function
      !io_selection type ref to cl_salv_selections
    raising
      cx_static_check. " Passes through static checks and handles (raises message)

endinterface.
