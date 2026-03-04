interface zif_sbcglib_view_cmd_handler
  public.

  methods on_user_command
    importing
      !iv_cmd       type salv_de_function
      !io_selection type ref to cl_salv_selections
    raising
      cx_static_check. " Passes through static checks and handles (raises message)

endinterface.
