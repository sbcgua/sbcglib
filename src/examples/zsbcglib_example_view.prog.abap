report zsbcglib_example_view.

class lcl_app definition.
  public section.

    interfaces zif_sbcglib_view_callbacks.
    interfaces zif_sbcglib_view_cmd_handler.

    class-methods new
      returning
        value(ro_instance) type ref to lcl_app.
    methods run.

  private section.

    types:
      begin of ty_dummy,
        client  type c length 10,
        country type c length 2,
        ref     type c length 10,
        amt     type p length 10 decimals 2,
        cur     type c length 3,
        tech    type c length 10,
        to_hide type c length 10,
      end of ty_dummy,
      ty_dummy_tab type standard table of ty_dummy with default key.

    methods demo_data returning value(r_tab) type ty_dummy_tab.

endclass.

class lcl_app implementation.

  method demo_data.

    field-symbols <i> like line of r_tab.

    append initial line to r_tab assigning <i>.
    <i>-client  = 'Big'.
    <i>-country = 'DE'.
    <i>-ref     = 'Inv1'.
    <i>-amt     = 1000.
    <i>-cur     = 'EUR'.

    append initial line to r_tab assigning <i>.
    <i>-client  = 'Big'.
    <i>-country = 'DE'.
    <i>-ref     = 'Inv2'.
    <i>-amt     = 2000.
    <i>-cur     = 'EUR'.

    append initial line to r_tab assigning <i>.
    <i>-client  = 'Small'.
    <i>-country = 'LU'.
    <i>-ref     = 'InvX'.
    <i>-amt     = 5000.
    <i>-cur     = 'EUR'.

  endmethod.

  method new.
    create object ro_instance.
  endmethod.

  method run.

    data lo type ref to zcl_sbcglib_view.

    lo = zcl_sbcglib_view=>create(
      it_content     = demo_data( )
      iv_title       = 'Demo view'
      iv_technames   = abap_true
      iv_pfstatus    = 'EXAMPLE' " No prog prefix as the status is in the current prog
      ii_cmd_handler = me
      ii_callbacks   = me
    )->hide_fields( 'tech' " No need if zcl_sbcglib_view_fieldcat is used
    )->set_aggregations( 'amt'
    )->set_sorting( '*client-'
    )->add_header( |Invoice\nList| ).

    lo->display( ).

  endmethod.


  method zif_sbcglib_view_callbacks~on_double_click.
    message iv_column type 'S'.
  endmethod.

  method zif_sbcglib_view_callbacks~setup_columns.
    io_columns->get_column( 'AMT' )->set_currency_column( 'CUR' ).
    " AND/OR
    zcl_sbcglib_view_fieldcat=>new(
    )->hide( 'to_hide'
    )->tech( 'tech'
    )->add( f = 'ref' opts = 'key' t = 'Reference No' st = 'RefNo'
    )->apply( io_columns = io_columns ).
    " TODO Extend FC_HELPER example
  endmethod.

  method zif_sbcglib_view_cmd_handler~on_user_command.
    case iv_cmd.
      when 'TEST'.
        message 'Test OK' type 'S'.
      when 'XXX'.
        message 'Secret level opened' type 'S'.
    endcase.
  endmethod.

endclass.

start-of-selection.
  lcl_app=>new( )->run( ).
