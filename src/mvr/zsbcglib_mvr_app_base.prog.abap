class lcl_app definition.

  public section.
    interfaces zif_sbcglib_view_cmd_handler.

    methods constructor
      importing
        is_selection type lcl_model=>ty_selection
        ii_modifiers_list_getter type ref to lif_modifiers_list_getter
      raising
        lcx_error.

    methods run
      raising
        lcx_error.

  private section.
    data mo_data  type ref to lcl_model.
    data mo_view  type ref to zcl_sbcglib_view.
    data mt_spool type lcl_model=>tty_spool.

    methods regenerate
      importing
        io_selection type ref to cl_salv_selections
      raising
        lcx_error.

endclass.

class lcl_app implementation.

  method constructor.

    create object mo_data
      exporting
        it_modifiers = ii_modifiers_list_getter->prepare_modifiers( )
        is_selection = is_selection.

    mo_view = lcl_view=>create(
      it_content     = mo_data->get_data( )
      ii_cmd_handler = me ).

  endmethod.

  method run.
    mo_view->display( ).
  endmethod.

  method zif_sbcglib_view_cmd_handler~on_user_command.

    case iv_cmd.
      when 'REGENERATE'.
        regenerate( io_selection ).
      when others.
*        mo_view->on_user_command(
*          iv_cmd = iv_cmd
*          io_selection = io_selection ).
    endcase.
  endmethod.

  method regenerate.

    data lt_list type lcl_model=>tt_list.

    mo_view->get_selected_records(
      changing
        ct_records =  lt_list ).
    if lines( lt_list ) = 0.
      lcx_error=>raise( 'Select at least one view to regenerate'(101) ).
    endif.
    mt_spool = mo_data->regenerate( lt_list ).
    mo_view->update_content( mo_data->get_data( ) ).

    lcl_view=>display_spool( changing ct_spool = mt_spool ).

  endmethod.

endclass.
