interface zif_sbcglib_view_callbacks
  public.

  " SPDX-License-Identifier: Apache-2.0
  " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
  " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib

  methods setup_columns
    importing
      !io_columns type ref to cl_salv_columns_table
      !io_aggrs type ref to cl_salv_aggregations
    raising
      cx_salv_error.

  methods on_double_click
    importing
      !iv_row type salv_de_row
      !iv_column type salv_de_column
      !iv_record type any
    raising
      cx_static_check. " Passes through static checks and handles (raises message)

endinterface.
