# "Templates" package functionality

This document describes public functionality of the SBCGLIB `templates` package.

## Reuse summary

- Use this package as a starting point for classical executable reports with selection screen, data-selection model, optional processing models, a controller, a reusable view wrapper, and centralized exception handling.
- Reuse by copying the template report and all its includes, then renaming and adapting the local classes/includes to the target program.
- Main entry point: `ZSBCGLIB_PROG_TEMPLATE` and its includes.
- Dependencies: intended to be used with `ERRORS`, `LOG`, `UTIL`, and `VIEW`.
- Agent note: do not treat the template includes as a runtime API. They are boilerplate to copy and adapt in a new report.

## Public functionality

The package contains boilerplates for reports to speed up typical program start. To reuse them, copy the program and all its includes and modify as needed.

## ZSBCGLIB_PROG_TEMPLATE

A boilerplate for a report with a selection screen and internal processing.

### Execution flow

`START-OF-SELECTION` → `PERFORM main` → builds `ls_selopt` from screen params → `lcl_app=>new( )=>run( )` → data selector → view display. All exceptions are caught in `main`: `zcx_sbcglib_error` (expected exception) and `cx_root` (unexpected) in separate blocks. Process user commands in either controller (`lcl_app`) or the view depending on their impact level.

### Includes

- `zsbcglib_prog_template` (main) - entry point. All OO includes come before the selection screen include so screen variables are never used directly in OO code.
- `zsbcglib_prog_template_sel` (selection screen) - declares program parameters.
- `zsbcglib_prog_template_def` (`lif_types`) - type definitions. Single local interface `lif_types` holds all types; intended for easy promotion to a global interface if needed.
- `zsbcglib_prog_template_data` (`lcl_data_selector`) - data selection model. Selects/imports and validates data; raises `zcx_sbcglib_error` on failure. Owns a log instance (`zif_sbcglib_log`), accessible via `get_log( )`.
- `zsbcglib_prog_template_model1` (`lcl_processor_sideeffect_only`) - optional processing model for side-effect-only operations (IMPORTING dataset, no changes returned).
- `zsbcglib_prog_template_model2` (`lcl_processor_with_change`) - optional processing model for operations that mutate the dataset (CHANGING parameter).
- `zsbcglib_prog_template_view` (`lcl_imported_view`) - view class based on `zcl_sbcglib_view` (see `view` package). Implements `zif_sbcglib_view_callbacks` (double-click, column setup via `zcl_sbcglib_view_fieldcat`) and `zif_sbcglib_view_cmd_handler` (view-local commands; unhandled commands forwarded to the controller). Holds a reference to the external data table (bound via `bind( CHANGING ct_dataset )`).
- `zsbcglib_prog_template_app` (`lcl_app`) - controller. Validates parameters, runs authorization check via `zcl_sbcglib_auth_utils`, creates `lcl_data_selector`, creates and displays the view, handles cross-class user commands via `zif_sbcglib_view_cmd_handler`.
