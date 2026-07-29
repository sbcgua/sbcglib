# "Errors" package functionality

This document describes public functionality of the SBCGLIB `errors` package.

## Reuse summary

- Use this package for small ABAP applications that need convenient, catchable exceptions with plain-text or T100 messages.
- Prefer `ZCX_SBCGLIB_ERROR` for expected, checked application errors and `ZCX_SBCGLIB_INTERNAL` for unexpected programming or invariant errors.
- Main entry points: `ZCX_SBCGLIB_ERROR=>RAISE_SIMPLE`, `RAISE_W_MSG`, `RAISE_WITH_SY`, `ASSERT_SUBRC`, `ASSERT_TRUE`, and `GET_BAPIRET2`.
- Dependencies: no SBCGLIB package dependency.
- Agent note: treat `ZCL_SBCGLIB_ERR_UTILS` as internal support code; do not recommend it as an application-facing API unless the user explicitly needs message formatting or call-point lookup.

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
- `RAISE_SIMPLE` method - raises message with free text
- both methods allow specifying message severity (`type`) which is then available via `MSG_TYPE` attribute
- both methods allow specifying dynamic args for the message - `V1` ... `V4` - where `V1` replaces `&1` placeholder in the message text, `V2` -> `&2` and so on.
- `RAISE_SIMPLE` can optionally add error location at the beginning of the message text if `W_LOC = abap_true`. The location will be also in `LOCATION` attribute
- `RAISE_SIMPLE` can optionally accept `RC` param which is then available via `RC` attribute - it stands for return code and can be used to identify exception in unit tests better
- `RAISE_WITH_SY` method raises error with attributes from current `SY` context
- Two convenient and catchable replacements for `assert`:
  - `ASSERT_SUBRC` method raises if `sy-subrc <> 0`
  - `ASSERT_TRUE` method raises if `test <> abap_true`, supposed to be called like this `zcx_sbcglib_error=>assert_true( boolc( condition_here ) )`
  - both methods optionally accept a custom message(`MSG`)
  - both methods add location at the beginning of the message (`W_LOC = abap_true`)
- `GET_BAPIRET2` method converts the error description into `BAPIRET2` type (to be used inside `catch`)

## ZCX_SBCGLIB_INTERNAL

`NO_CHECK` alternative to the `error` class, meant for internal errors:

- does not provide ability to raise with system message
- doesn't have `MSG_TYPE` as always supposed to be an error
- forces error location at the beginning of the message text. The location is then also accessible via `LOCATION` attribute.

Functionality:

- `RAISE` - raises error with plain `MSG` and, optionally, `RC` code
- `ASSERT_SUBRC` and `ASSERT_TRUE` - identical to those in `ZCX_SBCGLIB_ERROR` class
- `GET_BAPIRET2` - identical to the same feature of `ZCX_SBCGLIB_ERROR` class

## ZCL_SBCGLIB_ERR_UTILS

Error related utilities. Use with care, this class is not supposed to be public functionality and may change.

- `FORMAT_MESSAGE` - replaces `&x` in `MSG` with `Vx` param value
- `GET_CALL_POINT` - gets call stack item of the required depth
