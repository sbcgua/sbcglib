# "Errors" package functionality

This document describes public functionality of the SBCGLIB `errors` package.

## Public functionality

The package contains 2 exception classes, that are reused through the SBCGLIB itself and are convenient to use in applications that use SBCGLIB.

- `ZCX_SBCGLIB_ERROR` - inherited from `CX_STATIC_CHECK`
- `ZCX_SBCGLIB_INTERNAL` - inherited from `CX_NO_CHECK`, adds location of the error to the exception message (thus called `internal`)

The errors can be instantiated in the classic way with `raise` keyword, but the idea was to make it more convenient with static class methods which represent certain patterns. E.g. typical usage of `ZCX_SBCGLIB_ERROR` would be:

```abap
  zcx_sbcglib_error=>raise_simple( 'Error description' ).
```

## ZCX_SBCGLIB_ERROR

- `RAISE_W_MSG` method - raises error with a system message (T100)
- `RAISE_SIMPLE` method - raise message with free text
- both methods allows specifiyng message severity (`type`) which is then available via `MSG_TYPE` attribute
- both metods allows specifiying dynamic args for the message - `V1` ... `V4` - where `V1` replaces `$1` placeholder in the message text, `V2` -> `$2` and so on.
- `RAISE_SIMPLE` can optionally add error location at the beginning of the message text if `W_LOC = abap_true`
- `RAISE_SIMPLE` can optionally accept `RC` param which is then available via `RC` attribute - it stands for return code and can be used to identify exception in unit tests better
- `RAISE_WITH_SY` method raises error with attributes from current `SY` context
- Two convenient and catchable replacements for `assert`:
  - `ASSERT_SUBRC` method raises if `sy-subrc <> 0`, optionally with a custom message(`MSG`)
  - `ASSERT_TRUE` method raises if `test <> abap_true`, supposed to be called like this `zcx_sbcglib_error->assert_true( boolc( condition_here ) )`. optionally with a custom message(`MSG`)
- `GET_BAPIRET2` method converts the error description into `BAPIRET2` type (to be used inside `catch`)

## ZCX_SBCGLIB_INTERNAL

`NO_CHECK` alternative the the `error` class, yet supposed for internal errors, thus does not provide ability to raise with system message and does force error location at the beginning of the message text. The location is then also accessible via `LOCATION` attribute.

- `RAISE` - raises error with plain `MSG` and, optionally, `RC` code
- `ASSERT_SUBRC` and `ASSERT_TRUE` - identical to those in `ZCX_SBCGLIB_ERROR` class
- `GET_BAPIRET2` - identical to the same feature of `ZCX_SBCGLIB_ERROR` class

## ZCL_SBCGLIB_ERR_UTILS

Error related utilities. Use with care, this class is not supposed to be public functionality and may change.

- `FORMAT_MESSAGE` - replaces `$x` in `MSG` with `Vx` param value
- `GET_CALL_POINT` - get's call stack item of the required depth
