# SBCGLIB Log

Use the `LOG` package for in-memory message collection, manipulation, conversion to `BAPIRET2`, and simple UI display.

Do not use this package as SAP Application Log (`BC-SRV-BAL`) persistence or SLG1 logging. It is not a BAL wrapper.

## Main Objects

- `ZIF_SBCGLIB_LOG`: public interface for log operations and message table.
- `ZCL_SBCGLIB_LOG`: implementation of `ZIF_SBCGLIB_LOG`.
- `ZCL_SBCGLIB_LOG_VIEW`: popup/table display for a log; depends on the `VIEW` package.

Prefer variables typed as `REF TO zif_sbcglib_log`.

## Create And Add Messages

```abap
data li_log type ref to zif_sbcglib_log.

li_log = zcl_sbcglib_log=>new(
  i_msgid = 'ZMY_MSG'
  i_name  = 'Import log' ).

li_log->addm(
  ty = zif_sbcglib_log=>c_type-error
  no = '001'
  v1 = lv_docno ).

li_log->add_str(
  msg   = 'Free text message'
  ty    = zif_sbcglib_log=>c_type-warning
  index = lv_line_no ).
```

Shortcuts:

```abap
li_log->e( no = '001' v1 = lv_docno ).
li_log->w( no = '002' v1 = lv_docno ).
li_log->s( no = '003' v1 = lv_docno ).
```

Add exceptions:

```abap
li_log->add_if_t100_msg( lx_t100 ). "Preserves T100 msgid/msgno
li_log->addx( lx_any ).             "Stores get_text( ) as free text
```

Add BDC or system messages:

```abap
li_log->add_bdcmsgcoll( ls_bdcmsgcoll ).
li_log->add_sy( ).
```

## Query And Convert

```abap
if li_log->has_errors( ) = abap_true.
  lt_return = li_log->get_bapiret_tab( ).
endif.

if li_log->log_severity( ) >= zif_sbcglib_log=>c_severity-warning.
  "React to warnings or errors
endif.
```

Useful methods:

- `is_empty`: true when there are no messages.
- `has_warnings`, `has_errors`, `has_msg_no`.
- `size`, `get_first_message`, `get_first_message_text`.
- `log_severity`: numeric highest severity.
- `log_highest_msg_type`: ABAP message type symbol (`I`, `W`, `E`).
- `default_msgid`: constructor default message class.
- `clear`, `merge_with`, `set_severity`.

## Display

```abap
if li_log->is_empty( ) = abap_false.
  zcl_sbcglib_log_view=>display(
    ii_log   = li_log
    iv_title = 'Processing log' ).
endif.
```

## Notes

- `add_str` uses message `00/001`, splits text through `&1&2&3&4`, and is limited by SAP message variable lengths.
- Use `add_if_t100_msg` instead of `addx` when structured message id/number must survive.
- The optional `index` can represent source line/item number and is useful for sorting or display context.
