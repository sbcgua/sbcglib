# SBCGLIB Errors

Use the `ERRORS` package for concise, catchable exception handling in ABAP applications.

## Choose The Exception

- Use `ZCX_SBCGLIB_ERROR` for expected application errors that callers should catch. It inherits from `CX_STATIC_CHECK`.
- Use `ZCX_SBCGLIB_INTERNAL` for unexpected invariant/programming errors. It inherits from `CX_NO_CHECK` and always adds call location to the message.
- Avoid `ZCL_SBCGLIB_ERR_UTILS` in application code. It is support code for formatting messages and call-point lookup.

## Common Patterns

Raise plain text:

```abap
zcx_sbcglib_error=>raise_simple( 'Error description' ).
```

Raise plain text with severity and placeholders:

```abap
zcx_sbcglib_error=>raise_simple(
  msg  = 'Document &1 cannot be processed'
  type = 'E'
  v1   = lv_belnr ).
```

Raise a T100 message:

```abap
zcx_sbcglib_error=>raise_w_msg(
  msgid = 'ZMY_MSG'
  msgno = '001'
  v1    = lv_value
  type  = 'E' ).
```

Raise from current `sy-msg*` fields:

```abap
zcx_sbcglib_error=>raise_with_sy( ).
```

Use catchable assertions:

```abap
zcx_sbcglib_error=>assert_subrc( msg = 'Read failed' ).
zcx_sbcglib_error=>assert_true(
  test = boolc( lv_is_valid = abap_true )
  msg  = 'Invalid input' ).
```

Catch and show the original severity:

```abap
catch zcx_sbcglib_error into lx_error.
  message lx_error type 'S' display like lx_error->msg_type.
endcatch.
```

Convert to `BAPIRET2`:

```abap
ls_return = lx_error->get_bapiret2( ).
```

## Notes

- `RAISE_SIMPLE` stores severity in `MSG_TYPE`; default severity is error.
- `RAISE_SIMPLE` can accept `RC` for unit-test-friendly identification.
- Set `W_LOC = abap_true` when the user/developer message should include the ABAP call location.
- `ZCX_SBCGLIB_INTERNAL=>RAISE`, `ASSERT_SUBRC`, and `ASSERT_TRUE` are no-check alternatives and always represent error-level internal failures.
