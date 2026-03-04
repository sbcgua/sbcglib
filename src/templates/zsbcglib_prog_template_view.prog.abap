class lcl_imported_view definition final.
  public section.

    interfaces zif_sbcglib_view_callbacks.

    methods constructor
      importing
        ii_cmd_handler type ref to zif_sbcglib_view_cmd_handler.
    methods bind
      changing
        ct_dataset type lif_types=>ty_data_tab.
    methods display.

  private section.
    data mr_dataset type ref to lif_types=>ty_data_tab.
    data mo_view type ref to zcl_sbcglib_view.
    data mi_cmd_handler type ref to zif_sbcglib_view_cmd_handler.

endclass.

class lcl_imported_view implementation.

  method constructor.
    mi_cmd_handler = ii_cmd_handler.
  endmethod.

  method bind.
    get reference of ct_dataset into mr_dataset.
  endmethod.

  method display.

    mo_view = zcl_sbcglib_view=>create(
      it_content_ref = mr_dataset
      iv_title = 'Data report'(003)
*      iv_pfstatus = '' " TODO, copy of standard ALV to keep all sortings and etc
*      see FG SALV_METADATA_STATUS and it's GUI statuses SALV_TABLE_STANDARD and SALV_TABLE_STDPOPUP
      ii_callbacks = me
      ii_cmd_handler = me ).
    mo_view->display( ).

  endmethod.

  method zif_sbcglib_view_callbacks~on_double_click.

    case iv_column.
      when 'order_no'.
        " do some drill down
    endcase.

  endmethod.

  method zif_sbcglib_view_callbacks~setup_columns.

    zcl_sbcglib_view_fieldcat=>new(
      )->add( f = 'ORDER_NO'  t = 'Order No'(100)
      )->add( f = 'AMOUNT_NET' opts = 'sum,curf=curr'
      "...
      )->apply(
        io_columns = io_columns
        io_aggrs   = io_aggrs ).

    " Todo all texts, sums, curr ...

  endmethod.

  method zif_sbcglib_view_cmd_handler~on_user_command.

    case iv_cmd.
*      when 'CMD1'.
*        " view-related commands
      when others.
        " Process more global commands in controller, but depends on specifics ...
        mi_cmd_handler->on_user_command(
          iv_cmd = iv_cmd
          io_selection = io_selection ).
    endcase.

  endmethod.

endclass.
