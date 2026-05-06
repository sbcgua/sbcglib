# "Log" package functionality

This document describes public functionality of the SBCGLIB `log` package.

## Public functionality

The package contains a simple abstraction of a log and a view UI for it. It is in-memory log and is **NOT** related to "Application Log (BC-SRV-BAL)" native SAP functionality (BAL_LOG FMs). The main purpose is to conveniently collect set of messages from different sources, manipulate the log and display it to the user.

- interface `zif_sbcglib_log` - defines the log types and methods
- class `zcl_sbcglib_log` - implementation of the interface
- class `zcl_sbcglib_log_view` - UI to show the log, reuses `zcl_sbcglib_view` from the `view` package

## ZIF_SBCGLIB_LOG

The interface exposes readonly attributes:

- `messages` - list of added messages. The structure of the message is defined by `ty_message` type in the same interface
- `name` - optional name of the log, to distinguish between log instances programmatically (if required)

The interface also exposes constants:

- `c_type` - message type symbols: `info='I'`, `success='S'`, etc (see the code)
- `c_severity` - numeric severity levels used by `log_severity`: `none=0`, `info=1`, etc (see the code)

The interface exposes the following methods:

To add messages to the log:

- `addm` - adds a system message with params `id` (msgid), `ty` (msgty), `no` (msgno) and optional `v1`..`v4`. Optionally, pass `index` which can serve as an extra sorting parameter e.g. to represent a document line number. The `first` flag adds the message to the beginning of the message list. `id` falls back to the default msgid set in the constructor if not supplied
- `add_rec` - appends the message directly from argument of `ty_message` type
- `add_str` - adds a free string. Uses msgid `'00'` / msgno `'001'` (`&1&2&3&4` template), limited to 200 chars. Optional `index` and `ty` (default `'E'`)
- `addx` - adds an `if_message` (presumably an exception) to the log by calling `get_text()` and storing the result as a free-text string (structured msgid/no are **not** preserved)
- `add_bdcmsgcoll` - adds a batch input error (`bdcmsgcoll`)
- `add_sy` - adds a message collected in `sy`
- `add_if_t100_msg` - adds an `if_t100_message` (presumably an exception) preserving T100 message structure (msgid/msgno) via `cl_message_helper`. Prefer this over `addx` when structured message data matters. Supports `first` flag
- `w` - shortcut to `addm` but with hardcoded `W` (warning) message type
- `e` - shortcut to `addm` but with hardcoded `E` (error) message type
- `s` - shortcut to `addm` but with hardcoded `S` (success) message type

Log state methods:

- `is_empty` - returns `abap_true` if the log has zero lines
- `has_warnings` - returns `abap_true` if the log has warnings
- `has_errors` - returns `abap_true` if the log has errors
- `has_msg_no` - returns `abap_true` if the log has a message matching `id` (optional) and `no`
- `size` - returns number of messages
- `get_first_message` - returns first message of from the list in the form of `ty_message` record
- `get_first_message_text` - returns string representation of the first message in the list
- `get_bapiret_tab` - converts log to `bapirettab`
- `log_severity` - returns the highest severity present in the log as a numeric `ty_severity` - thus enables to check if severity of the log higher than the expected. Severities are defined in `c_severity` constants (`none=0`, `info=1`...). Message type `'X'` (abort) is treated as error-level
- `log_highest_msg_type` - returns the highest severity as an ABAP message type symbol (`'I'`, `'W'`, `'E'`). `'X'` is treated as `'E'`
- `default_msgid` - returns default `msgid` for the log if it was assigned during construction

Log mass manipulations:

- `clear` - clears the log
- `merge_with` - appends messages from the passed log into the current instance. Optional `set_severity` parameter overrides the message type of all imported messages
- `set_severity` - forces the given severity to all messages already in the log

## ZCL_SBCGLIB_LOG

The class implements the `zif_sbcglib_log` interface. The log can be instantiated with a constructor or `new` method, both have the same parameters:

- optional `i_msgid` - the default message id to be added to methods, that supplies system messages
- optional `i_name` - to distinguish between log instances programmatically (copied to `zif_sbcglib_log~name`) e.g. specifying the log source or purpose

## ZCL_SBCGLIB_LOG_VIEW

Supposed to be called as follows:

```abap
  zcl_sbcglib_log_view=>display(
    ii_log = li_log_instance
    iv_title = 'My log' ).
```

... passing along the log instance and, optionally, title for the modal window.

The method returns an exit command code, which is now a constant - this is reserved for potential future features.
