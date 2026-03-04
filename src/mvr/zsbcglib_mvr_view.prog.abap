class lcl_view definition.
  public section.

    interfaces zif_sbcglib_view_callbacks.

    class-methods create
      importing
        it_content     type any table
        ii_cmd_handler type ref to zif_sbcglib_view_cmd_handler
      returning
        value(ro_view) type ref to zcl_sbcglib_view.

    class-methods display_spool
      changing
        ct_spool type lcl_model=>tty_spool.

  private section.

    data mo_view type ref to zcl_sbcglib_view.

    class-methods call_view_maintenance
      importing
        iv_view type csequence
      raising
        lcx_error.

endclass.

class lcl_view implementation.

  method create.

    data lo type ref to lcl_view.

    create object lo.
    lo->mo_view = zcl_sbcglib_view=>create(
      iv_title = 'Regenerate table maintenance dialog'(002)
      it_content = it_content
      ii_cmd_handler = ii_cmd_handler
      ii_callbacks = lo
      iv_pfstatus = 'MAIN'
      iv_selection_mode = if_salv_c_selection_mode=>row_column ).
    lo->mo_view->enable_layout_variants( |{ sy-cprog }| ).
    ro_view = lo->mo_view.

  endmethod.


  method zif_sbcglib_view_callbacks~setup_columns.

    zcl_sbcglib_view_fieldcat=>new(
      )->add( f = 'STATUS'  opts = 'icon' t = 'Status'(100)
      )->add( f = 'GENDATE'               t = 'GenDate'(102)
      )->add( f = 'GENTIME'               t = 'GenTime'(103)
      )->add( f = 'SHOW_LOG'              t = 'Log'(105)
      )->add( f = 'GEN_TIMESTAMP' opts = 'tech'
      )->apply( io_columns = io_columns ).

    try.
      io_columns->set_cell_type_column( 'CELL_TYPE' ).
    catch cx_salv_data_error.
    endtry.

  endmethod.

  method zif_sbcglib_view_callbacks~on_double_click.

    data lt_spool type lcl_model=>tty_spool.
    field-symbols <rec> type lcl_model=>ty_list.

    assign iv_record to <rec>.
    assert sy-subrc = 0.
    if <rec>-tabname is initial.
      return.
    endif.
    if iv_column = 'SHOW_LOG'.
      lt_spool = <rec>-spool_log.
      display_spool( changing ct_spool = lt_spool ).
    else.
      call_view_maintenance( <rec>-tabname ).
    endif.

  endmethod.

  method call_view_maintenance.

    data lv_message type string.

    call function 'VIEW_MAINTENANCE_CALL'
      exporting
        action                       = 'U'
        view_name                    = iv_view
      exceptions
        client_reference             = 1
        foreign_lock                 = 2
        invalid_action               = 3
        no_clientindependent_auth    = 4
        no_database_function         = 5
        no_editor_function           = 6
        no_show_auth                 = 7
        no_tvdir_entry               = 8
        no_upd_auth                  = 9
        only_show_allowed            = 10
        system_failure               = 11
        unknown_field_in_dba_sellist = 12
        view_not_found               = 13
        others                       = 14.
    if sy-subrc <> 0.
      message id sy-msgid type 'E' number sy-msgno with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        into lv_message.
      lcx_error=>raise( lv_message ).
    endif.

  endmethod.

  method zif_sbcglib_view_cmd_handler~on_user_command.
  endmethod.

  method display_spool.

    data lo_table type ref to cl_salv_table.

    if ct_spool is initial.
      return.
    endif.

    try.
      cl_salv_table=>factory(
        importing
          r_salv_table   = lo_table
        changing
          t_table        = ct_spool ).

      lo_table->display( ).
    catch cx_salv_msg.
      message 'Error in cl_salv_table=>factory' type 'I' display like 'E'.
      return.
    endtry.

  endmethod.

endclass.
