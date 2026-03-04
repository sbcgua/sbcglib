class lcl_app definition final.
  public section.
    interfaces zif_sbcglib_view_cmd_handler.
    methods constructor
      importing
        i_selopt type lif_types=>ty_selopt.
    methods run
      raising
        zcx_sbcglib_error.
  private section.
    data ms_selopt type lif_types=>ty_selopt.
    data mt_dataset type lif_types=>ty_data_tab.
    data mi_log type ref to zif_sbcglib_log.

    methods check_auth
      raising
        zcx_sbcglib_error.
endclass.

class lcl_app implementation.

  method constructor.
    ms_selopt = i_selopt.
  endmethod.

  method run.

    if ms_selopt-vkorg is initial.
      zcx_sbcglib_error=>raise_simple( 'Specify sales org' ).
    endif.

    check_auth( ).

    if ms_selopt-filepath is initial.
      zcx_sbcglib_error=>raise_simple( 'Specify file path' ).
    endif.

    " TODO other checks ...

    data lo_data_selector type ref to lcl_data_selector.
    data lx_error type ref to zcx_sbcglib_error.

    lo_data_selector = lcl_data_selector=>new( ms_selopt-filepath ).

    try.
      mt_dataset = lo_data_selector->read( ).
    catch zcx_sbcglib_error into lx_error.
      zcl_sbcglib_log_view=>display( lo_data_selector->get_log( ) ).
      raise exception lx_error.
    endtry.

    data lo_view type ref to lcl_imported_view.

    create object lo_view exporting ii_cmd_handler = me.
    lo_view->bind( changing ct_dataset = mt_dataset ).

    lo_view->display( ).

  endmethod.

  method check_auth.

    zcl_sbcglib_auth_utils=>check_vbak_vko(
      i_vkorg = ms_selopt-vkorg
      i_actvt = zcl_sbcglib_auth_utils=>c_bkpf_buk_actvt-create ).

  endmethod.

  method zif_sbcglib_view_cmd_handler~on_user_command.

    case iv_cmd.
      when 'PROC1'.

        data lo_proc1 type ref to lcl_processor_with_change.
        create object lo_proc1.

        lo_proc1->do_stuff( changing ct_dataset = mt_dataset ).
        mi_log = lo_proc1->get_log( ).

      when 'PROC2'.

        data lo_proc2 type ref to lcl_processor_sideeffect_only.
        create object lo_proc2.

        lo_proc2->do_stuff( mt_dataset ).
        mi_log = lo_proc2->get_log( ).

      when 'SHOW_LOG'.
        zcl_sbcglib_log_view=>display( mi_log ).

    endcase.

  endmethod.

endclass.
