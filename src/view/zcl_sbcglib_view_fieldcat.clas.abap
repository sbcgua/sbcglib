class zcl_sbcglib_view_fieldcat definition
  public
  final
  create public.

  public section.

    class-methods new
      returning
        value(ro_instance) type ref to zcl_sbcglib_view_fieldcat.

    methods add
      importing
        f    type csequence
        t    type clike optional
        st   type clike optional
        lt   type clike optional
        f4   type string optional
        opts type string optional
      returning
        value(ro_instance) type ref to zcl_sbcglib_view_fieldcat.

    methods tech
      importing
        f type csequence
      returning
        value(ro_instance) type ref to zcl_sbcglib_view_fieldcat.

    methods hide
      importing
        f type csequence
      returning
        value(ro_instance) type ref to zcl_sbcglib_view_fieldcat.

    methods defaults
      importing
        opts type string
      returning
        value(ro_instance) type ref to zcl_sbcglib_view_fieldcat.

    methods apply
      importing
        io_columns type ref to cl_salv_columns_table optional
        io_column  type ref to cl_salv_column optional
        io_aggrs   type ref to cl_salv_aggregations optional
      changing
        cs_field type lvc_s_fcat optional.

    methods build_lvc
      importing
        i_tab type any
      returning
        value(rt_fieldcat) type lvc_t_fcat.

    methods build_slis
      importing
        i_tab type any
      returning
        value(rt_fieldcat) type slis_t_fieldcat_alv.

  protected section.
  private section.

    types:
      begin of ty_field,
        name type lvc_s_fcat-fieldname,
        f4   type string,
        text type lvc_s_fcat-scrtext_m,
        stxt type lvc_s_fcat-scrtext_s,
        ltxt type lvc_s_fcat-scrtext_l,
        len  type i,
        ord  type i,
        cur  type lvc_s_fcat-cfieldname,
        unit type lvc_s_fcat-qfieldname,
        color type lvc_s_colo,
        opts type string_table,
      end of ty_field.
    types:
      tty_fields type sorted table of ty_field with unique key name
        with non-unique sorted key by_ord components ord.

    constants c_no_auto_order_marker type i value -9999.

    data mv_auto_order_index type i.
    data mt_fields type tty_fields.
    data mt_default_opts type string_table.
    data:
      begin of globals,
        do_optimize type abap_bool,
        auto_order  type abap_bool,
        reset_key   type abap_bool,
      end of globals.

    methods validate_type_get_components
      importing
        i_tab type any
      returning
        value(rt_components) type abap_component_view_tab.

    methods add_opt_safe
      importing
        f type csequence
        opt type string optional.

    methods parse_opts
      importing
        opts type string
      changing
        cs_field type ty_field.

    methods apply_fcat
      changing
        cs_field type lvc_s_fcat.

    methods apply_salv_all
      importing
        io_columns type ref to cl_salv_columns_table
        io_aggrs   type ref to cl_salv_aggregations optional.

    methods apply_salv_one
      importing
        io_column  type ref to cl_salv_column
        io_aggrs   type ref to cl_salv_aggregations optional
        io_columns type ref to cl_salv_columns_table optional. " to set order

ENDCLASS.



CLASS ZCL_SBCGLIB_VIEW_FIELDCAT IMPLEMENTATION.


  method add.

    data ls_field like line of mt_fields.
    data lv_field_name type string.
    data lv_implicit_opts type string.

    split f at ',' into lv_field_name lv_implicit_opts.
    ls_field-name = to_upper( lv_field_name ).
    ls_field-f4   = to_upper( f4 ).
    ls_field-text = t.
    ls_field-stxt = st.
    ls_field-ltxt = lt.

    parse_opts(
      exporting
        opts = lv_implicit_opts && ',' && opts
      changing
        cs_field = ls_field ).

    if globals-auto_order = abap_true.
      if ls_field-ord = c_no_auto_order_marker.
        clear ls_field-ord.
      else.
        mv_auto_order_index = mv_auto_order_index + 1.
        ls_field-ord = mv_auto_order_index.
      endif.
    endif.

    insert ls_field into table mt_fields.

    ro_instance = me.

  endmethod.


  method add_opt_safe.

    field-symbols <f> like line of mt_fields.
    data lv_fname like <f>-name.

    lv_fname = f.
    read table mt_fields assigning <f> with key name = lv_fname.
    if sy-subrc = 0.
      append opt to <f>-opts.
    else.
      add( f = f opts = opt ).
    endif.

  endmethod.


  method apply.

    if cs_field is supplied and cs_field is not initial.
      apply_fcat( changing cs_field = cs_field ).
    elseif io_column is bound.
      apply_salv_one(
        io_column = io_column
        io_aggrs = io_aggrs ).
    elseif io_columns is bound.
      apply_salv_all(
        io_columns = io_columns
        io_aggrs = io_aggrs ).
    endif.

  endmethod.


  method apply_fcat.

    field-symbols <f> like line of mt_fields.
    field-symbols <opts> like <f>-opts.
    field-symbols <o> like line of <opts>.

    read table mt_fields assigning <f> with key name = cs_field-fieldname.
    if sy-subrc = 0.
      if <f>-len > 0.
        cs_field-outputlen = <f>-len.
      endif.

      if <f>-ord > 0.
        cs_field-col_pos = <f>-ord.
      elseif <f>-ord < 0.
        " this method does not see size of structure so just put negative fields to the end, which may be not 100% accurate
        cs_field-col_pos = 999999.
      endif.

      if <f>-text is not initial.
        cs_field-coltext = <f>-text.
      endif.

      if <f>-f4 is not initial.
        split <f>-f4 at '-' into cs_field-ref_table cs_field-ref_field.
      endif.

      if <f>-cur is not initial.
        cs_field-cfieldname = <f>-cur.
      endif.

      if <f>-unit is not initial.
        cs_field-qfieldname = <f>-unit.
      endif.

      if <f>-color is not initial.
        cs_field-emphasize = |C{ <f>-color-col }{ <f>-color-int }{ <f>-color-inv }|.
      endif.

      assign <f>-opts to <opts>.
    else.
      assign mt_default_opts to <opts>.
    endif.

    loop at <opts> assigning <o>.
      case <o>.
        when 'nof4'.
          cs_field-f4availabl = abap_false.
        when 'tech'.
          cs_field-tech = abap_true.
        when 'icon'.
          cs_field-icon = abap_true.
        when 'hotspot'.
          cs_field-hotspot = abap_true.
        when 'edit'.
          cs_field-edit = abap_true.
        when 'chk' or 'checkbox'.
          cs_field-checkbox = abap_true.
        when 'no_out' or 'hide'.
          cs_field-no_out = abap_true.
        when 'sum'.
          cs_field-do_sum = abap_true.
        when 'key' or 'nokey'.
          cs_field-key = boolc( <o> = 'key' ).
      endcase.
    endloop.

  endmethod.


  method apply_salv_all.

    data lt_columns type salv_t_column_ref.
    field-symbols <c> like line of lt_columns.
    field-symbols <f> like line of mt_fields.

    lt_columns = io_columns->get( ).

    loop at lt_columns assigning <c>.
      apply_salv_one(
        io_columns = io_columns
        io_column = <c>-r_column
        io_aggrs  = io_aggrs ).
    endloop.

    if globals-auto_order = abap_true.
      loop at mt_fields assigning <f> using key by_ord.
        check <f>-ord > 0.
        io_columns->set_column_position(
          columnname = <f>-name
          position   = <f>-ord ).
      endloop.
    endif.

*    if mv_do_optimize = abap_true.
*      io_columns->set_optimize( ).
*    endif.

  endmethod.


  method apply_salv_one.

    data lo_column type ref to cl_salv_column_table.
    data lv_colname type lvc_fname.

    lo_column ?= io_column. " Hmmm ?
    lv_colname = lo_column->get_columnname( ).

    field-symbols <f> like line of mt_fields.
    field-symbols <opts> like <f>-opts.
    field-symbols <o> like line of <opts>.

    read table mt_fields assigning <f> with key name = lv_colname.
    if sy-subrc = 0.

      data lv_output_len type lvc_outlen.
      if <f>-len > 0.
        lv_output_len = <f>-len.
        lo_column->set_output_length( lv_output_len ).
      elseif globals-do_optimize = abap_true.
        lo_column->set_optimized( ).
      endif.

      if globals-reset_key = abap_true.
        lo_column->set_key( abap_false ).
      endif.

      if <f>-ord <> 0 and globals-auto_order = abap_false and io_columns is bound.
        " In case of auto_order it is done in apply_all
        if <f>-ord > 0.
          io_columns->set_column_position(
            columnname = lv_colname
            position   = <f>-ord ).
        else.
          " From the end, not 100% accurate because of set_column_position applies the order immediately
          io_columns->set_column_position(
            columnname = lv_colname
            position   = lines( io_columns->get( ) ) + 1 + <f>-ord ).
        endif.
      endif.

      if <f>-text is not initial.

        if <f>-stxt is not initial.
          lo_column->set_short_text( |{ <f>-stxt }| ).
        else.
          lo_column->set_short_text( |{ <f>-text }| ).
        endif.

        if <f>-ltxt is not initial.
          lo_column->set_long_text( |{ <f>-ltxt }| ).
        else.
          lo_column->set_long_text( |{ <f>-text }| ).
        endif.

        lo_column->set_medium_text( |{ <f>-text }| ).
        lo_column->set_long_text( |{ <f>-text }| ).

      endif.

      if <f>-f4 is not initial.
        data ls_ddic type salv_s_ddic_reference.
        split <f>-f4 at '-' into ls_ddic-table ls_ddic-field.
        lo_column->set_ddic_reference( ls_ddic ).
        lo_column->set_f4( abap_true ).
      endif.

      try.
          if <f>-cur is not initial.
            lo_column->set_currency_column( <f>-cur ).
          endif.
          if <f>-unit is not initial.
            lo_column->set_quantity_column( <f>-unit ).
          endif.
        catch cx_salv_error ##NO_HANDLER. " Fail silently
      endtry.

      if <f>-color is not initial.
        lo_column->set_color( <f>-color ).
      endif.

      assign <f>-opts to <opts>.
    else.
      if globals-do_optimize = abap_true.
        lo_column->set_optimized( ).
      endif.

      if globals-reset_key = abap_true.
        lo_column->set_key( abap_false ).
      endif.

      assign mt_default_opts to <opts>.
    endif.

    loop at <opts> assigning <o>.
      case <o>.
        when 'nof4'.
          lo_column->set_f4( if_salv_c_bool_sap=>false ).
        when 'tech'.
          lo_column->set_technical( if_salv_c_bool_sap=>true ).
        when 'icon'.
          lo_column->set_icon( if_salv_c_bool_sap=>true ).
        when 'hotspot'.
          lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
*        when 'edit'.
          " Salv does not support edit natively
        when 'chk' or 'checkbox'.
          lo_column->set_cell_type( if_salv_c_cell_type=>checkbox ).
        when 'no_out' or 'hide'.
          lo_column->set_visible( if_salv_c_bool_sap=>false ).
        when 'sum'.
          if io_aggrs is bound.
            try.
                io_aggrs->add_aggregation(
                  columnname  = lv_colname
                  aggregation = if_salv_c_aggregation=>total ).
              catch cx_salv_data_error.                 "#EC NO_HANDLER
              catch cx_salv_not_found.                  "#EC NO_HANDLER
              catch cx_salv_existing.                   "#EC NO_HANDLER
            endtry.
          endif.
        when 'key' or 'nokey'.
          lo_column->set_key( boolc( <o> = 'key' ) ).
      endcase.
    endloop.

  endmethod.


  method build_lvc.

    data lo_etype type ref to cl_abap_elemdescr.
    data lt_components type abap_component_view_tab.

    field-symbols <c> like line of lt_components.
    field-symbols <f> like line of rt_fieldcat.

    lt_components = validate_type_get_components( i_tab ).

    loop at lt_components assigning <c>.
      check <c>-type->kind = cl_abap_typedescr=>kind_elem.
      lo_etype ?= <c>-type.

      append initial line to rt_fieldcat assigning <f>.
      <f>-col_pos   = sy-tabix.
      <f>-fieldname = <c>-name.

      if <c>-name = 'MANDT'.
        <f>-tech = abap_true.
      endif.

      if lo_etype->is_ddic_type( ) = abap_true.
        data ls_ddic type dfies.
        ls_ddic = lo_etype->get_ddic_field( ).
        <f>-rollname   = ls_ddic-rollname.
        <f>-domname    = ls_ddic-domname.
        if ls_ddic-inttype <> 'D'. " No need for f4 for dates
          <f>-f4availabl = ls_ddic-f4availabl.
        endif.
        <f>-lowercase = ls_ddic-lowercase.
        <f>-reptext   = ls_ddic-reptext.
        <f>-scrtext_s = ls_ddic-scrtext_s.
        <f>-scrtext_m = ls_ddic-scrtext_m.
        <f>-scrtext_l = ls_ddic-scrtext_l.
      endif.

      if <f>-rollname is initial.
        <f>-inttype  = lo_etype->type_kind.
        <f>-intlen   = lo_etype->length.
        <f>-decimals = lo_etype->decimals.
      endif.

      if lo_etype->edit_mask is not initial.
        data lv_exit like lo_etype->edit_mask.
        lv_exit = lo_etype->edit_mask.
        shift lv_exit left deleting leading '='.
        <f>-convexit = lv_exit.
      endif.

      apply_fcat( changing cs_field = <f> ).
    endloop.

  endmethod.


  method build_slis.

    data lt_fieldcat type lvc_t_fcat.
    field-symbols <src> like line of lt_fieldcat.
    field-symbols <dst> like line of rt_fieldcat.

    lt_fieldcat = build_lvc( i_tab ).
    loop at lt_fieldcat assigning <src>.
      append initial line to rt_fieldcat assigning <dst>.
      move-corresponding <src> to <dst>.
      if <src>-coltext is not initial.
        <dst>-seltext_s = <src>-coltext.
        <dst>-seltext_m = <src>-coltext.
        <dst>-seltext_l = <src>-coltext.
      endif.
    endloop.

  endmethod.


  method defaults.

    data lt_opts type string_table.
    field-symbols <o> like line of lt_opts.

    split opts at ',' into table lt_opts.

    loop at lt_opts assigning <o>.
      condense <o>.
      <o> = to_lower( <o> ).
      if <o> = 'autoorder' or <o> = 'auto_order'.
        globals-auto_order = abap_true.
      elseif <o> = 'optimize'.
        globals-do_optimize = abap_true.
      elseif <o> = 'reset_key'.
        globals-reset_key = abap_true.
      elseif <o> is not initial.
        append <o> to mt_default_opts.
      endif.
    endloop.

    sort mt_default_opts.
    delete adjacent duplicates from mt_default_opts.

    ro_instance = me.

  endmethod.


  method hide.

    add_opt_safe( f = f opt = 'no_out' ).
    ro_instance = me.

  endmethod.


  method new.
    create object ro_instance.
  endmethod.


  method parse_opts.

    data lt_opts type string_table.
    data lv_color type string.
    field-symbols <o> like line of lt_opts.

    split opts at ',' into table lt_opts.

    loop at lt_opts assigning <o>.
      condense <o>.
      <o> = to_lower( <o> ).

      if <o> is initial.
        continue.
      elseif <o> cp 'len=*'.
        cs_field-len = substring_after( val = <o> sub = `=` ).
      elseif <o> cp 'ord=*'.
        cs_field-ord = substring_after( val = <o> sub = `=` ).
      elseif <o> cp 'curf=*'.
        cs_field-cur = to_upper( substring_after( val = <o> sub = `=` ) ).
      elseif <o> cp 'unit=*'.
        cs_field-unit = to_upper( substring_after( val = <o> sub = `=` ) ).
      elseif <o> cp 'col=*'.
        lv_color = substring_after( val = <o> sub = `=` ).
        check strlen( lv_color ) = 3 and lv_color co '0123456789'.
        cs_field-color-col = lv_color+0(1).
        cs_field-color-int = lv_color+1(1).
        cs_field-color-inv = lv_color+2(1).
      elseif <o> = 'no_auto_ord'.
        cs_field-ord = c_no_auto_order_marker.
      else.
        append <o> to cs_field-opts.
      endif.
    endloop.

    sort cs_field-opts.
    delete adjacent duplicates from cs_field-opts.

  endmethod.


  method tech.

    add_opt_safe( f = f opt = 'tech' ).
    ro_instance = me.

  endmethod.


  method validate_type_get_components.

    data lo_type  type ref to cl_abap_typedescr.
    data lo_rtype type ref to cl_abap_refdescr.
    data lo_ttype type ref to cl_abap_tabledescr.
    data lo_stype type ref to cl_abap_structdescr.
    data lt_components type abap_component_view_tab.

    lo_type = cl_abap_typedescr=>describe_by_data( i_tab ).

    if lo_type->kind = lo_type->kind_ref.
      lo_rtype ?= lo_type.
      lo_type   = lo_rtype->get_referenced_type( ).
    endif.

    if lo_type->kind <> lo_type->kind_table.
      zcx_sbcglib_view_error=>raise( 'Unexpected i_tab type' ).
    endif.

    lo_ttype ?= lo_type.
    lo_stype ?= lo_ttype->get_table_line_type( ).
    rt_components = lo_stype->get_included_view( ).

  endmethod.
ENDCLASS.
