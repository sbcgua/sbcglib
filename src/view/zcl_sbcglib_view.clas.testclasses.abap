class ltcl_view_demo definition final
  for testing
  risk level harmless
  duration short.

  public section.

    interfaces zif_sbcglib_view_callbacks.

  private section.

    types:
      begin of ty_dummy,
        client  type c length 10,
        country type c length 2,
        ref     type c length 10,
        amt     type p length 10 decimals 2,
        cur     type c length 3,
        tech    type c length 10,
      end of ty_dummy,
      ty_dummy_tab type standard table of ty_dummy with default key.

    methods demo_data returning value(r_tab) type ty_dummy_tab.
    methods demo. " for testing.
    methods demo_popup. " for testing.

endclass.

class ltcl_view_demo implementation.

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

  method demo.

    data lo type ref to zcl_sbcglib_view.

    lo = zcl_sbcglib_view=>create(
      it_content = demo_data( )
      iv_title   = 'Demo view'
      iv_technames = abap_true
      ii_callbacks = me
    )->hide_fields( 'tech'
    )->set_aggregations( 'amt'
    )->set_sorting( '*client-'
    )->add_header( |Invoice\nList| ).

    lo->display( ).

  endmethod.

  method demo_popup.

    data lo type ref to zcl_sbcglib_view.

    lo = zcl_sbcglib_view=>create_popup(
      it_content = demo_data( )
      iv_title   = 'Demo view'
      iv_technames = abap_true
      ii_callbacks = me
    )->hide_fields( 'tech'
    )->set_aggregations( 'amt'
    )->set_sorting( '*client-'
    )->add_header( |Invoice\nList| ).

    lo->display( ).

  endmethod.

  method zif_sbcglib_view_callbacks~on_double_click.
    message iv_column type 'S'. " For debug only, suppressed in UTs
  endmethod.

  method zif_sbcglib_view_callbacks~on_user_command.
    if iv_cmd = 'XXX'.
      message 'Secret level opened' type 'S'. " For debug only, suppressed in UTs
    endif.
  endmethod.

  method zif_sbcglib_view_callbacks~setup_columns.
    io_columns->get_column( 'AMT' )->set_currency_column( 'CUR' ).
  endmethod.

endclass.
