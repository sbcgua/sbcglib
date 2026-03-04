class zcl_sbcglib_view definition
  public
  final
  create public.

  public section.

    " SPDX-License-Identifier: Apache-2.0
    " SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
    " Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib


    " Construction

    class-methods create
      importing
        it_content     type any table optional
        it_content_ref type ref to data optional
        iv_title       type csequence default 'View'
        iv_technames   type abap_bool default abap_false
        iv_pfstatus    type string optional
        ii_callbacks   type ref to zif_sbcglib_view_callbacks optional
        ii_cmd_handler type ref to zif_sbcglib_view_cmd_handler optional
        iv_selection_mode type salv_de_constant default if_salv_c_selection_mode=>none
        i_container    type ref to cl_gui_container optional
      returning
        value(ro_view) type ref to zcl_sbcglib_view.

    class-methods create_popup
      importing
        it_content      type any table optional
        it_content_ref  type ref to data optional
        iv_title        type csequence default 'View'
        iv_technames    type abap_bool default abap_false
        iv_popup_width  type i default 45
        iv_popup_height type i default 10
        iv_pfstatus     type string optional
        ii_callbacks    type ref to zif_sbcglib_view_callbacks optional
        ii_cmd_handler  type ref to zif_sbcglib_view_cmd_handler optional
        iv_selection_mode type salv_de_constant default if_salv_c_selection_mode=>none
      returning
        value(ro_view) type ref to zcl_sbcglib_view.

    methods constructor
      importing
        it_content     type any table optional
        it_content_ref type ref to data optional
        iv_title       type csequence default 'View'
        iv_technames   type abap_bool default abap_false
        iv_pfstatus    type string optional
        ii_callbacks   type ref to zif_sbcglib_view_callbacks optional
        ii_cmd_handler type ref to zif_sbcglib_view_cmd_handler optional
        iv_selection_mode type salv_de_constant default if_salv_c_selection_mode=>none
        i_container    type ref to cl_gui_container optional.

    " Runtime

    methods display.
    methods close.
    methods refresh.
    methods update_content
      importing
        it_content type any table.
    methods get_selected_records
      changing
        ct_records type standard table.

    " Events

    methods handle_double_click
      for event double_click of cl_salv_events_table
      importing
        row
        column.
    methods on_alv_user_command
      for event added_function of cl_salv_events
      importing
        e_salv_function.
    methods on_link_click
      for event link_click of cl_salv_events_table
      importing
        row
        column.

    " Controls

    methods get_salv_instance
      returning
        value(ro_salv) type ref to cl_salv_table.
    methods set_sorting
      importing
        iv_fields type any
      returning
        value(ro_self) type ref to zcl_sbcglib_view .
    methods set_aggregations
      importing
        iv_fields type any
      returning
        value(ro_self) type ref to zcl_sbcglib_view.
    methods hide_fields
      importing
        iv_fields type any
      returning
        value(ro_self) type ref to zcl_sbcglib_view.
    methods add_header
      importing
        iv_line type csequence
      returning
        value(ro_self) type ref to zcl_sbcglib_view.
    methods set_tooltip " DO NOT USE< WILL BE REFACTORED
      importing
        iv_value type lvc_value
        iv_type type salv_de_constant
        iv_tooltip type lvc_tip
      returning
        value(ro_self) type ref to zcl_sbcglib_view.
    methods enable_layout_variants
      importing
        iv_variant_key type repid
      returning
        value(ro_self) type ref to zcl_sbcglib_view.

  protected section.
  private section.

    data mo_alv type ref to cl_salv_table.
    data mr_data type ref to data.
    data mi_callbacks type ref to zif_sbcglib_view_callbacks.
    data mi_cmd_handler type ref to zif_sbcglib_view_cmd_handler.
    data mv_using_data_directly type abap_bool.

    methods set_column_tech_names.

    methods set_default_layout
      importing
        iv_title type lvc_title.

    methods set_screen_status
      importing
        iv_pfstatus type string.

    methods set_default_handlers.

    methods copy_content
      importing
        it_contents type any table.

    methods create_alv
      importing
        i_container	type ref to cl_gui_container optional.

    methods set_columns_default
      importing
        iv_technames type abap_bool default abap_false.

    methods normalize_list_of_fields
      importing
        iv_fields type any
      returning
        value(rt_fields) type string_table.

ENDCLASS.



CLASS ZCL_SBCGLIB_VIEW IMPLEMENTATION.


  method add_header.

    data lt_header type string_table.
    data lo_header  type ref to cl_salv_form_layout_grid.
    data lo_h_label type ref to cl_salv_form_label.
    data lo_h_flow  type ref to cl_salv_form_layout_flow.
    field-symbols <txt> like line of lt_header.

    split iv_line at |\n| into table lt_header.

    if lines( lt_header ) = 0.
      return.
    endif.

    create object lo_header.

    loop at lt_header assigning <txt>.
      if sy-tabix = 1.
        lo_h_label = lo_header->create_label( row = 1 column = 1 ).
        lo_h_label->set_text( <txt> ).
      else.
        lo_h_flow = lo_header->create_flow( row = sy-tabix column = 1 ).
        lo_h_flow->create_text( text = <txt> ).
      endif.
    endloop.

    mo_alv->set_top_of_list( lo_header ).
    mo_alv->set_top_of_list_print( lo_header ).

    ro_self = me.

  endmethod.


  method close.
    mo_alv->close_screen( ).
  endmethod.


  method constructor.

    if boolc( lines( it_content ) <> 0 ) = boolc( it_content_ref is not initial ). " XOR
      zcx_sbcglib_view_error=>raise( 'One and Only one of contents must be supplied' ).
    endif.

    if it_content_ref is not initial.
      mv_using_data_directly = abap_true.
      mr_data = it_content_ref.
    else.
      copy_content( it_content ).
    endif.

    create_alv( i_container ).

    set_default_layout( |{ iv_title }| ).

    if iv_pfstatus is not initial.
      set_screen_status( iv_pfstatus ).
    endif.

    if ii_cmd_handler is bound.
      mi_cmd_handler = ii_cmd_handler.
    endif.
    if ii_callbacks is bound.
      mi_callbacks = ii_callbacks.
    endif.
    set_default_handlers( ).

    if iv_selection_mode is not initial.
      mo_alv->get_selections( )->set_selection_mode( iv_selection_mode ).
    endif.

    set_columns_default( iv_technames = iv_technames ).

  endmethod.


  method copy_content.

    data lo_ttype type ref to cl_abap_tabledescr.
    data lo_stype type ref to cl_abap_structdescr.

    if mr_data is initial.
      lo_ttype ?= cl_abap_typedescr=>describe_by_data( it_contents ).
      lo_stype ?= lo_ttype->get_table_line_type( ).
      lo_ttype = cl_abap_tabledescr=>create( lo_stype ). "ensure standard table
      create data mr_data type handle lo_ttype.
    endif.

    field-symbols <tab> type standard table.
    assign mr_data->* to <tab>.
    <tab> = it_contents.

  endmethod.


  method create.

    create object ro_view
      exporting
        it_content = it_content
        it_content_ref = it_content_ref
        iv_title = iv_title
        iv_technames = iv_technames
        iv_pfstatus = iv_pfstatus
        ii_callbacks = ii_callbacks
        ii_cmd_handler = ii_cmd_handler
        iv_selection_mode = iv_selection_mode
        i_container = i_container.

  endmethod.


  method create_alv.

    data lx_alv type ref to cx_salv_error.
    field-symbols <tab> type standard table.

    assign mr_data->* to <tab>.

    try.
      if i_container is bound.
        cl_salv_table=>factory(
          exporting
            r_container = i_container
          importing
            r_salv_table = mo_alv
          changing
            t_table      = <tab> ).

      else.
        cl_salv_table=>factory(
          importing
            r_salv_table = mo_alv
          changing
            t_table      = <tab> ).

      endif.
    catch cx_salv_msg into lx_alv.
      zcx_sbcglib_view_error=>raise( lx_alv->get_text( ) ).
    endtry.

  endmethod.


  method create_popup.

    create object ro_view
      exporting
        it_content = it_content
        it_content_ref = it_content_ref
        iv_title = iv_title
        iv_technames = iv_technames
        iv_pfstatus = iv_pfstatus
        ii_callbacks = ii_callbacks
        ii_cmd_handler = ii_cmd_handler
        iv_selection_mode = iv_selection_mode.

    ro_view->mo_alv->set_screen_popup(
      start_column = 5
      end_column   = 5 + iv_popup_width
      start_line   = 5
      end_line     = 1 + iv_popup_height ).

  endmethod.


  method display.
    mo_alv->display( ).
  endmethod.


  method enable_layout_variants.

    data lo_layout type ref to cl_salv_layout.
    data ls_layout_key type salv_s_layout_key.

    " Add possibility to save table layout
    lo_layout = mo_alv->get_layout( ).
    ls_layout_key-report = iv_variant_key.
    lo_layout->set_key( ls_layout_key ).
    lo_layout->set_default( abap_true ).
    lo_layout->set_save_restriction( ).

    ro_self = me.

  endmethod.


  method get_salv_instance.
    ro_salv = mo_alv.
  endmethod.


  method get_selected_records.

    data lo_selections type ref to cl_salv_selections.
    data lt_rows       type salv_t_row.
    data ls_row        like line of lt_rows.

    field-symbols <tab> type standard table.
    field-symbols <rec> type any.

    clear ct_records.

    lo_selections = mo_alv->get_selections( ).
    lt_rows = lo_selections->get_selected_rows( ).

    assign mr_data->* to <tab>.

    loop at lt_rows into ls_row.
      read table <tab> assigning <rec> index ls_row.
      if sy-subrc = 0.
        append <rec> to ct_records.
      endif.
    endloop.

  endmethod.


  method handle_double_click.

    field-symbols <ls_sel> type any.
    field-symbols <lt_tab> type standard table.
    data lx type ref to cx_root.

    if mi_callbacks is not bound.
      return.
    endif.
    assign mr_data->* to <lt_tab>.
    read table <lt_tab> assigning <ls_sel> index row.
    if sy-subrc is not initial.
      return.
    endif.

    try.
      mi_callbacks->on_double_click( iv_row = row iv_column = column iv_record = <ls_sel> ).
    catch cx_root into lx.
      message lx type 'I' display like 'E'.
    endtry.

  endmethod.


  method hide_fields.

    data lx_alv    type ref to cx_salv_error.
    data lt_fields type string_table.
    data lv_field  type string.
    data lo_cols   type ref to cl_salv_columns_table.

    lo_cols   = mo_alv->get_columns( ).
    lt_fields = normalize_list_of_fields( iv_fields ).

    loop at lt_fields into lv_field.
      try.
        lo_cols->get_column( |{ lv_field }| )->set_visible( abap_false ).
      catch cx_salv_error into lx_alv.
        " Ignore
      endtry.
    endloop.

    ro_self = me.

  endmethod.


  method normalize_list_of_fields.

    data lt_fields type string_table.
    data lv_fld    type string.
    field-symbols <fields> type string_table.

    case cl_abap_typedescr=>describe_by_data( iv_fields )->type_kind.
      when 'C' or 'g'.              " Value, assume char like
        split iv_fields at ',' into table lt_fields.
        assign lt_fields to <fields>.
      when 'h'.                     " Table, assume string table
        assign iv_fields to <fields>.
      when others.
        zcx_sbcglib_view_error=>raise( 'Wrong field list parameter' ).
    endcase.

    loop at <fields> into lv_fld.
      lv_fld = to_upper( lv_fld ).
      condense lv_fld.
      if lv_fld is not initial.
        append lv_fld to rt_fields.
      endif.
    endloop.

  endmethod.


  method on_alv_user_command.

    data lx type ref to cx_root.
    data li_cmd_handler type ref to zif_sbcglib_view_cmd_handler.

    li_cmd_handler = mi_cmd_handler.
    if li_cmd_handler is not bound.
      li_cmd_handler = mi_callbacks.
      " TODO maybe refactor ... crutchy
    endif.
    if li_cmd_handler is not bound.
      return.
    endif.

    try.
      li_cmd_handler->on_user_command(
        iv_cmd       = e_salv_function
        io_selection = mo_alv->get_selections( ) ).
    catch cx_root into lx.
      message lx type 'S' display like 'E'.
    endtry.

  endmethod.


  method on_link_click.
    handle_double_click(
      row    = row
      column = column ).
  endmethod.


  method refresh.
    mo_alv->refresh( ).
  endmethod.


  method set_aggregations.

    data lx_alv    type ref to cx_salv_error.
    data lo_agg type ref to cl_salv_aggregations.
    data lt_fields type string_table.
    data lv_field  type string.

    lo_agg    = mo_alv->get_aggregations( ).
    lt_fields = normalize_list_of_fields( iv_fields ).

    try.
      loop at lt_fields into lv_field.
        lo_agg->add_aggregation(
          columnname  = |{ lv_field }|
          aggregation = if_salv_c_aggregation=>total ).
      endloop.
    catch cx_salv_data_error cx_salv_not_found cx_salv_existing into lx_alv.
      zcx_sbcglib_view_error=>raise( lx_alv->get_text( ) ).
    endtry.

    ro_self = me.

  endmethod.


  method set_columns_default.

    assert mr_data is not initial.

    data lo_ttype type ref to cl_abap_tabledescr.
    data lo_stype type ref to cl_abap_structdescr.
    data lo_cols type ref to cl_salv_columns_table.
    data lo_col type ref to cl_salv_column.
    data lx_alv type ref to cx_salv_error.

    field-symbols <c> like line of lo_stype->components.

    lo_cols = mo_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).

    lo_ttype ?= cl_abap_typedescr=>describe_by_data_ref( mr_data ).
    lo_stype ?= lo_ttype->get_table_line_type( ).

    try.
      loop at lo_stype->components assigning <c>.
        lo_col = lo_cols->get_column( columnname = <c>-name ).

        if <c>-type_kind = cl_abap_typedescr=>typekind_packed.
          lo_col->set_sign( abap_true ).
        endif.

        if <c>-name = 'MANDT'.
          lo_col->set_visible( abap_false ).
        endif.

        if iv_technames = abap_true.
          lo_col->set_short_text( |{ <c>-name }| ).
          lo_col->set_medium_text( |{ <c>-name }| ).
          lo_col->set_long_text( |{ <c>-name }| ).
        endif.

      endloop.
    catch cx_salv_not_found.
      " Ignore
    endtry.

    if mi_callbacks is bound.
      try.
        mi_callbacks->setup_columns(
          io_columns = lo_cols
          io_aggrs   = mo_alv->get_aggregations( ) ).
      catch cx_salv_error into lx_alv.
        zcx_sbcglib_view_error=>raise( lx_alv->get_text( ) ).
      endtry.
    endif.

  endmethod.


  method set_column_tech_names.

    " Reserved for future use or to remove ...

    data lo_cols type ref to cl_salv_columns.
    data lt_columns type salv_t_column_ref.

    lo_cols = mo_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).
    lt_columns = lo_cols->get( ).

    field-symbols <c> like line of lt_columns.
    loop at lt_columns assigning <c>.
      <c>-r_column->set_short_text( |{ <c>-columnname }| ).
      <c>-r_column->set_medium_text( |{ <c>-columnname }| ).
      <c>-r_column->set_long_text( |{ <c>-columnname }| ).
    endloop.

  endmethod.


  method set_default_handlers.

    data lo_event type ref to cl_salv_events_table.
    lo_event = mo_alv->get_event( ).

    if mi_callbacks is bound or mi_cmd_handler is bound.
      set handler on_alv_user_command for lo_event.
    endif.

    if mi_callbacks is bound.
      set handler handle_double_click for lo_event.
      set handler on_link_click for lo_event.
    endif.

  endmethod.


  method set_default_layout.

    data lo_functions type ref to cl_salv_functions_list.
    lo_functions = mo_alv->get_functions( ).
*    lo_functions->set_default( abap_true ).
    lo_functions->set_all( abap_true ).

    data lo_display type ref to cl_salv_display_settings.
    lo_display = mo_alv->get_display_settings( ).
    lo_display->set_striped_pattern( abap_true ).
    lo_display->set_list_header( iv_title ).

  endmethod.


  method set_screen_status.

    data lv_prog type string.
    data lv_pfstatus type string.

    split iv_pfstatus at '/' into lv_prog lv_pfstatus.
    if lv_pfstatus is initial.
      lv_pfstatus = lv_prog.
      lv_prog     = sy-cprog.
    endif.

    " Defaults:
    " see FG SALV_METADATA_STATUS
    " and it's GUI statuses SALV_TABLE_STANDARD and SALV_TABLE_STDPOPUP

    mo_alv->set_screen_status(
      pfstatus = |{ lv_pfstatus }|
      report   = |{ lv_prog }| ).

  endmethod.


  method set_sorting.

    data lx_alv    type ref to cx_salv_error.
    data lo_sorts  type ref to cl_salv_sorts.
    data lt_fields type string_table.
    data lv_field  type string.
    data lv_subtotal type abap_bool.
    data lv_order_salv type salv_de_sort_sequence.
    data lv_order  type c length 1.

    lo_sorts  = mo_alv->get_sorts( ).
    lt_fields = normalize_list_of_fields( iv_fields ).

    try.
      loop at lt_fields into lv_field.
        lv_subtotal = boolc( '*' = substring( val = lv_field len = 1 ) ).
        if lv_subtotal = abap_true.
          lv_field = substring( val = lv_field off = 1 ).
        endif.
        lv_order = substring( val = lv_field len = 1 off = strlen( lv_field ) - 1 ).
        lv_order_salv = if_salv_c_sort=>sort_up.
        if lv_order ca '+-'.
          lv_field = substring( val = lv_field len = strlen( lv_field ) - 1 ).
          if lv_order ca '-'.
            lv_order_salv = if_salv_c_sort=>sort_down.
          endif.
        endif.

        lo_sorts->add_sort(
          columnname = |{ lv_field }|
          sequence   = lv_order_salv
          subtotal   = lv_subtotal ).
      endloop.
    catch cx_salv_error into lx_alv.
      zcx_sbcglib_view_error=>raise( lx_alv->get_text( ) ).
    endtry.

    ro_self = me.

  endmethod.


  method set_tooltip.

    data lo_tooltips type ref to cl_salv_tooltips.
    data lx_alv      type ref to cx_salv_existing.

    lo_tooltips = mo_alv->get_functional_settings( )->get_tooltips( ).

    try.
      lo_tooltips->add_tooltip(
        type    = iv_type
        value   = iv_value
        tooltip = iv_tooltip ).
    catch cx_salv_existing.
      zcx_sbcglib_view_error=>raise( lx_alv->get_text( ) ).
    endtry.

    ro_self = me.

  endmethod.


  method update_content.

    if mv_using_data_directly = abap_true.
      zcx_sbcglib_view_error=>raise( 'Cannot update view with direct data usage' ).
    endif.
    copy_content( it_content ).
    mo_alv->refresh( ).

  endmethod.
ENDCLASS.
