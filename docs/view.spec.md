# "View" package functionality

This document describes public functionality of the SBCGLIB `view` package.

## Public functionality

- the components of the class use own exception `ZCX_SBCGLIB_VIEW_ERROR` (of no_check type, to pass through potential wrappers or composable interfaces)

- `ZCL_SBCGLIB_VIEW` - a wrapper around SALV to make displaying typical grid layout simpler
- `ZCL_SBCGLIB_VIEW_POPUPS` a class of static wrappers for standard SAP popups, to be called in object-oriented style.
- `ZCL_SBCGLIB_VIEW_FIELDCAT` - a convenience wrapper around field catalog maintenance

Interfaces:

- `ZIF_SBCGLIB_VIEW_CMD_HANDLER` - a callback interface to handle user commands (e.g. for `ZCL_SBCGLIB_VIEW`)
- `ZIF_SBCGLIB_VIEW_CALLBACKS` - a callback interface to be used in `ZCL_SBCGLIB_VIEW` to handle double clicks and fine ALV layout setup

## ZCL_SBCGLIB_VIEW

The typical usage would look like:

```abap
  zcl_sbcglib_view=>create(
    it_content  = lt_content_to_display
    iv_title    = 'View header title'
    iv_pfstatus = 'ZPROGRAM/MY_SCREEN_STATUS' " case INsensitive (uppercase internally)
    ii_callbacks = me " the class instance handling callbacks
    ii_cmd_handler = me  " the class instance handling user commands
  )->display( ).
```

which will: display data from `lt_content_to_display`, use screen status `MY_SCREEN_STATUS` from `ZPROGRAM` (the program name can be omited, if the screen status belongs to the current program), forward command handling and callbacks like double click to the calling class.

- `it_content` vs `it_content_ref` - use `ref` option if you want to display a large table in place (otherwise it is copied which increases memory usage). Exactly one of the two must be provided — supplying neither or both raises an exception.
- set `iv_technames` to display the technical names of the fields rather than human-friendly names
- `ii_callbacks` and `ii_cmd_handler` are separated, because sometimes handling of the commands belongs to a different class than double click and ALV setup (see docs for the interfaces)
  - if an exception was raised within the handlers, it would be caught by the class and displayed to user as a message
- `iv_selection_mode` - passed to the ALV
- optionally place the ALV into `i_container` GUI container

Another construction method `create_popup` works in the similar way, just displays the modal version of the SALV. Use `iv_popup_width` and `iv_popup_height` to control the windows size.

Runtime methods:

- `display` - displays the view
- `close` - closes the view
- `refresh` - refreshes the view
- `update_content` - re-uploads the data to the grid (in case `it_content` was used) and refreshes the view
- `get_selected_records` - get the selected records of the original table (not only their indexes)

Extra configuration before calling `display`:

- `get_salv_instance` - returns the underlying SALV instance
- `set_sorting` - sets sorting order in the table, accepts either a `string_table` or a comma-delimited string of fields. Each field may optionally have `*` prefix to set subtotal and/or `+`/`-` prefix to set sorting order, e.g.: `'field1,-field2,*field3,*-field4'`, where fields 3 and 4 will have subtotals and field 2 and 4 will be sorted in descending order
- `set_aggregations` - sets record grouping in the table, accepts either a `string_table` or a comma-delimited string of fields
- `hide_fields` - hides given fields (`string_table` or a comma-delimited string). As a simpler alternative to `zcl_sbcglib_view_fieldcat` setup
- `add_header` - adds alv text header. Accepts multiline string (`\n` separated)
- `enable_layout_variants` - allows saving layout variants. Key should be unique, e.g. `|{ sy-cprog }_BY_INVOICE|`

## Callback Interfaces

- `ZIF_SBCGLIB_VIEW_CMD_HANDLER` provides the `on_user_command` that is called if a custom command in ALV is invoked. The method also receives `cl_salv_selections` instance to know what is selected in the grid. It is OK to raise errors inside the handler - it will be caught by the VIEW class.
- `ZIF_SBCGLIB_VIEW_CALLBACKS` contains 2 methods:
  - `setup_columns` that is called before the SALV display, receives `cl_salv_columns_table` and `cl_salv_aggregations` and thus allows fine-tuning the ALV layout, in particular with `zcl_sbcglib_view_fieldcat`
  - `on_double_click` - the handler for double click, receives row and column indexes and the full selected data record
  - both can safely raise exceptions within
- The interfaces are deliberately separated, it allows handling different aspects in different classes. It may be appropriate to dedicate a custom view class around the `ZCL_SBCGLIB_VIEW` and handle layout setup and double click handling when it is relatively complex. While the user commands are frequently related to the higher layer of logic (controller). Besides the command handler class can be reused in other patterns e.g. dynpros (although without `cl_salv_selections`).

## ZCL_SBCGLIB_VIEW_FIELDCAT

The field catalog setup (unless fully derived from DDIC) is usually a very unreadable piece of code. This class was designed to make it readable (although less type-checked).

It would typically be called from `setup_columns` callback and look like follows:

```abap
  zcl_sbcglib_view_fieldcat=>new(
    )->defaults( 'auto_order, optimize'
    )->add( f = 'STATUS' opts = 'icon'
    )->add( f = 'CHECKBOX_FIELD' opts = 'chk'
    )->add( f = 'PARTY_CODE'     opts = 'key'
    )->add( f = 'PARTY_NAME'     t = |{ 'Parter name'(102) }| st = |{ 'PartName'(101) }|
    )->add( f = 'AMOUNT'         opts = 'sum,curf=currency'
    )->add( f = 'CURRENCY'
    )->add( f = 'TEXT'           opts = 'len=20'
    )->add( f = 'TECH_FIELD'     opts = 'hide'
    )->hide( 'ANOTHER_TECH_FIELD'
    )->apply( 
      io_columns = io_columns
      io_aggrs   = io_aggrs ).
```

which would: set ALV order of fields in the order of adding to catalog, optimize column width, set `status` field as icon, set `checkbox_field` as check box, color `party_code` as key field, set text and short text of `party_name`, set aggregation for `amount` field with reference to `currency` as currency field, limit `text` size to 20 symbols (visually), hide `tech_field` and `another_tech_field`.

Methods meaning:

- `add` - adds a field info to catalog, params:
  - `f` - field name (can be lowercased)
  - `t`, `st`, `lt` - medium text, short and long texts respectively
  - `f4` - reference table for the search help (e.g. `t001-bukrs`)
  - `opts` - options, applied to the field, comma-separated:
    - `len=x` - fix display length of the column
    - `ord=x` - set order of the field
    - `curf=x` - sets the currency field for an amount field
    - `unit=x` - sets the currency field for a quantity field
    - `col=x` - sets color of the field
    - `key` or `nokey` - sets or forcefully unsets "key" flag of the alv column
    - `nof4` - suppress search help
    - `tech` - set field as technical (not possible to display after)
    - `hide` or `no_out` - hide field (possible to display after)
    - `chk` or `checkbox` - set field as check box
    - `icon` - set field as icon
    - `hotspot` - set field as hotspot (also useful to make clickable checkbox in a readonly SALV)
    - `sum` - enable aggregation for the field
- `tech` mark field as technical (cannot be displayed later, e.g. for `mandt`)
- `hide` hide field (a shorter version of `hide` opt), can be displayed later (sets `no_out` alv field param)
- `defaults` allows specifying default options for all fields in the catalog, even for the unmentioned:
  - `hide` - hide all unmentioned fields by default
  - `autoorder` or `auto_order` - set field order in the order of their adding to the catalog (unless redefined via `ord` opt for a specific field)
  - `optimize` - optimize column width
  - `reset_key` - force "key" flag reset for all the field unless `key` is specified via opts - useful when some field derive "key" flag from ddic

Ordering logic:

- if `autoorder` is specified, the field appear in the order of adding
- `ord=x` sets the order of the specific field, if `x` is negative - it start from the end

Catalog application methods:

- method `apply` applies the configuration to a SALV. Massively, via `cl_salv_columns_table` and `cl_salv_aggregations` instances, or to an individual column via `io_column`, or to an `lvc_s_fcat` field catalog entry via `cs_field`.
- method `build_lvc` attempts to build a default field catalog in a form of `lvc_t_fcat` type based on real data `i_tab`. (for old ALV classes)
- method `build_slis` attempts to build a default field catalog in a form of `slis_t_fieldcat_alv` type based on real data `i_tab`. (for old ALV classes)

## ZCL_SBCGLIB_VIEW_POPUPS

- `popup_to_confirm` method - wrapper around standard 'POPUP_TO_CONFIRM' FM. Returns `'1'` (button 1), `'2'` (button 2), or `'A'` (cancel).
- `popup_get_values` method - wrapper around standard 'POPUP_GET_VALUES' FM. `ev_code` is empty when values were entered, `'A'` when cancelled.
- `popup_get_one_value` method - a leaner version of `popup_get_values` for one field, allowing to specify table and field via `iv_field` param as `<table>-<field>`
- `popup_to_confirm_with_message` method - wrapper around standard 'POPUP_TO_CONFIRM_WITH_MESSAGE' FM
- `popup_to_select` method - simplified wrapper around 'REUSE_ALV_POPUP_TO_SELECT' FM. Accepts title, field catalog and data lines, returns index of selected table item
