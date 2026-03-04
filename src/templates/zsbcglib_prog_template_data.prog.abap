class lcl_data_selector definition final.
  public section.

    types ty_dataset type lif_types=>ty_data_tab.

    class-methods new
      importing
        i_filepath type string
      returning
        value(ro_instance) type ref to lcl_data_selector.
    methods constructor
      importing
        i_filepath type string.
    methods read
      returning
        value(rt_tab) type ty_dataset
      raising
        zcx_sbcglib_error.
    methods get_log
      returning
        value(ri_log) type ref to zif_sbcglib_log.

  private section.

    data m_filepath type string.
    data mi_log type ref to zif_sbcglib_log.

endclass.

class lcl_data_selector implementation.

  method new.

    create object ro_instance
      exporting
        i_filepath = i_filepath.

  endmethod.

  method constructor.

    m_filepath = i_filepath.
    mi_log = zcl_sbcglib_log=>new( i_name = 'Import log' ).

  endmethod.

  method get_log.

    ri_log = mi_log.

  endmethod.

  method read.

    " select / import
    " convert
    " validate

    field-symbols <i> like line of rt_tab.

    append initial line to rt_tab assigning <i>.

    <i>-date      = sy-datum.
    <i>-order_no  = '123'.
    <i>-item_text = 'Hello product'.
    <i>-qty       = '123.123'.
    <i>-unit      = 'KG'.
    <i>-price     = '40.56'.
    <i>-amount_net = '200.45'.
    <i>-amount_vat = '34.01'.
    <i>-curr       = 'UAH'.


    if mi_log->log_severity( ) > zif_sbcglib_log=>c_severity-info.
      zcx_sbcglib_error=>raise_simple( 'Import failed, check log' ).
    else.
      mi_log->add_str(
        msg = 'Import successful'
        ty  = zif_sbcglib_log=>c_type-success ).
    endif.

  endmethod.

endclass.
