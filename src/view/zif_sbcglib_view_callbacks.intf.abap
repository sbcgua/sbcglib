interface zif_sbcglib_view_callbacks
  public.

  interfaces zif_sbcglib_view_cmd_handler.

  aliases on_user_command
    for zif_sbcglib_view_cmd_handler~on_user_command.

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
