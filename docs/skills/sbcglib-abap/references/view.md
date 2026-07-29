# SBCGLIB View

Use the `VIEW` package for classical ABAP GUI/SALV table displays with compact OO setup, callbacks, command handling, popups, and readable field catalog configuration.

Do not use it for Fiori/Web UI, fully editable ALV grids, or requirements needing complete low-level SALV control.

## Main Objects

- `ZCL_SBCGLIB_VIEW`: SALV wrapper.
- `ZIF_SBCGLIB_VIEW_CALLBACKS`: column setup and double-click callback.
- `ZIF_SBCGLIB_VIEW_CMD_HANDLER`: custom user command handler.
- `ZCL_SBCGLIB_VIEW_FIELDCAT`: fluent field catalog/layout helper.
- `ZCL_SBCGLIB_VIEW_POPUPS`: OO wrappers for common SAP popup function modules.
- `ZCX_SBCGLIB_VIEW_ERROR`: no-check exception used by the package.

## Display A Table

```abap
zcl_sbcglib_view=>create(
  it_content        = lt_content
  iv_title          = 'Result'
  iv_pfstatus       = 'ZPROGRAM/MY_STATUS'
  ii_callbacks      = me
  ii_cmd_handler    = me
  iv_selection_mode = if_salv_c_selection_mode=>row_column
)->display( ).
```

Use `it_content_ref` instead of `it_content` for large tables when copying is undesirable. Supply exactly one of `it_content` or `it_content_ref`.

Use `create_popup` for modal display:

```abap
zcl_sbcglib_view=>create_popup(
  it_content       = lt_content
  iv_title         = 'Choose item'
  iv_popup_width   = 100
  iv_popup_height  = 25
)->display( ).
```

## Callback Interfaces

Use `ZIF_SBCGLIB_VIEW_CALLBACKS` for layout and double-click behavior:

```abap
method zif_sbcglib_view_callbacks~setup_columns.
  zcl_sbcglib_view_fieldcat=>new(
    )->defaults( 'auto_order, optimize'
    )->add( f = 'STATUS' opts = 'icon'
    )->add( f = 'AMOUNT' opts = 'sum,curf=CURRENCY'
    )->add( f = 'CURRENCY'
    )->hide( 'TECH_FIELD'
    )->apply(
      io_columns = io_columns
      io_aggrs   = io_aggrs ).
endmethod.

method zif_sbcglib_view_callbacks~on_double_click.
  "iv_record contains the selected row as generic data
endmethod.
```

Use `ZIF_SBCGLIB_VIEW_CMD_HANDLER` for toolbar/user commands:

```abap
method zif_sbcglib_view_cmd_handler~on_user_command.
  case iv_cmd.
    when 'PROCESS'.
      "Use io_selection to inspect selected rows
  endcase.
endmethod.
```

Exceptions raised inside callbacks/handlers are caught by the view wrapper and shown as messages.

## Runtime And Configuration

Useful methods before `display`:

- `set_sorting( 'FIELD1,FIELD2-,*FIELD3' )`: supports comma strings or `string_table`; `-` means descending, `*` means subtotal.
- `set_aggregations( 'AMOUNT' )`.
- `hide_fields( 'MANDT,TECH_FIELD' )`.
- `add_header( |Line 1\nLine 2| )`.
- `enable_layout_variants( |{ sy-cprog }_KEY| )`.
- `get_salv_instance( )`: use only when direct SALV access is truly needed.
- Avoid `set_tooltip`; it is unstable.

Useful runtime methods:

- `display`, `close`, `refresh`.
- `update_content`: reload data when the view was created with `it_content`; not valid with direct `it_content_ref`.
- `get_selected_records`: returns selected original table records, not only indexes.

## Field Catalog Helper

Call `ZCL_SBCGLIB_VIEW_FIELDCAT` from `setup_columns`.

Common `add` parameters:

- `f`: field name, case-insensitive.
- `t`, `st`, `lt`: medium, short, long text.
- `f4`: DDIC search-help reference such as `T001-BUKRS`.
- `opts`: comma-separated options.

Common `opts`:

- `len=x`, `ord=x`, `curf=FIELD`, `unit=FIELD`, `col=xyz`.
- `key`, `nokey`, `nof4`, `tech`, `hide`/`no_out`.
- `chk`/`checkbox`, `icon`, `hotspot`, `sum`.
- `no_auto_ord`: skip auto ordering for this field.
- `edit`: sets editable flag for old field catalogs; SALV does not support native editing, so use with care.

Defaults:

- `hide`: hide unmentioned fields.
- `autoorder` or `auto_order`: order fields by `add` call sequence.
- `optimize`: optimize column width.
- `reset_key`: unset DDIC-derived key flag unless explicitly set.

`build_lvc( i_tab )` and `build_slis( i_tab )` build old ALV field catalogs from runtime data.

Notes:

- it is not mandatory to set texts if the field has DDIC type - the class will extract the texts from the Data element.
- it is also not mandatory to specify all texts. If the length fits, you can only pass `t` - it will be compied to short and long texts, if they are not supplied.
- it is not mandatory to `add` all fields - unless you have `default = hide`, all fields will be shown, so `add` only fields with some deviations from default (ordering, text, special opts).

## Popups

Use `ZCL_SBCGLIB_VIEW_POPUPS` for standard dialogs:

- `popup_to_confirm`: returns `'1'`, `'2'`, or `'A'`.
- `popup_get_values`: wraps `POPUP_GET_VALUES`; `ev_code` is empty for entered values and `'A'` for cancel.
- `popup_get_one_value`: one-field wrapper using `<table>-<field>` in `iv_field`.
- `popup_to_confirm_with_message`.
- `popup_to_select`: wraps `REUSE_ALV_POPUP_TO_SELECT`, returns selected table index.
