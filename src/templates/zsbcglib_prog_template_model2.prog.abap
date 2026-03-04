class lcl_processor_with_change definition final.
  public section.

    methods constructor.

    methods do_stuff
      changing
        ct_dataset type lif_types=>ty_data_tab
      raising
        zcx_sbcglib_error.

    methods get_log
      returning
        value(ri_log) type ref to zif_sbcglib_log.

  private section.

    data mi_log type ref to zif_sbcglib_log.

endclass.

class lcl_processor_with_change implementation.

  method constructor.
    mi_log = zcl_sbcglib_log=>new( i_name = 'Processing log 2' ).
  endmethod.

  method get_log.
    ri_log = mi_log.
  endmethod.

  method do_stuff.

    " Do stuff
    " Record some data back to dataset

  endmethod.

endclass.
