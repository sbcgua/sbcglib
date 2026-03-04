class lcl_processor_sideeffect_only definition final.
  public section.

    methods constructor.

    methods do_stuff
      importing
        it_dataset type lif_types=>ty_data_tab
      raising
        zcx_sbcglib_error.

    methods get_log
      returning
        value(ri_log) type ref to zif_sbcglib_log.

  private section.

    data mi_log type ref to zif_sbcglib_log.

endclass.

class lcl_processor_sideeffect_only implementation.

  method constructor.
    mi_log = zcl_sbcglib_log=>new( i_name = 'Procesing log 1' ).
  endmethod.

  method get_log.
    ri_log = mi_log.
  endmethod.

  method do_stuff.

    " process

  endmethod.

endclass.
