# SBCGLIB Templates

Use the `TEMPLATES` package as boilerplate for classical executable ABAP reports. Do not treat template includes as runtime APIs.

## Reuse Model

Copy `ZSBCGLIB_PROG_TEMPLATE` and all its includes into the target report namespace, then adapt local classes, types, selection screen, and processing logic.

Expected dependencies:

- `ERRORS` for `ZCX_SBCGLIB_ERROR`.
- `LOG` for `ZIF_SBCGLIB_LOG` and `ZCL_SBCGLIB_LOG`.
- `UTIL` for authorization and optional helpers.
- `VIEW` for SALV display and callbacks.

## Execution Flow

`START-OF-SELECTION` -> `PERFORM main` -> build `ls_selopt` from selection-screen values -> create `lcl_app` -> `run( )` -> select/import data -> process optionally -> display view.

`main` catches:

- `ZCX_SBCGLIB_ERROR` for expected business/application errors and displays using the exception severity.
- `CX_ROOT` for unexpected errors and displays as error-like message.

## Include Roles

- `zsbcglib_prog_template`: main report entry point and include order.
- `zsbcglib_prog_template_sel`: selection-screen declarations.
- `zsbcglib_prog_template_def`: `lif_types` local interface for shared types. Promote to a global interface if reused elsewhere.
- `zsbcglib_prog_template_data`: `lcl_data_selector`, responsible for selecting/importing/validating data and owning a `zif_sbcglib_log`.
- `zsbcglib_prog_template_model1`: optional side-effect-only processor with IMPORTING dataset.
- `zsbcglib_prog_template_model2`: optional mutating processor with CHANGING dataset.
- `zsbcglib_prog_template_view`: `lcl_imported_view`, a wrapper around `ZCL_SBCGLIB_VIEW`; implements view callbacks and view-local commands.
- `zsbcglib_prog_template_app`: `lcl_app` controller; validates parameters, checks authorization, creates data selector, creates/displays view, and handles cross-class commands.

## Adaptation Checklist

1. Rename the report and includes to the target program namespace.
2. Keep OO includes before the selection-screen include so local classes do not use screen globals directly.
3. Replace `lif_types` structures with target selection and data types.
4. Adapt `zsbcglib_prog_template_sel` and map screen fields to `ls_selopt` in `main`.
5. Implement data retrieval/validation in `lcl_data_selector`; raise `ZCX_SBCGLIB_ERROR` for expected problems.
6. Keep or remove the optional processor includes depending on whether the report performs side effects or mutates the dataset.
7. Configure `lcl_imported_view` with `ZCL_SBCGLIB_VIEW_FIELDCAT` in `setup_columns`.
8. Put view-local commands in `lcl_imported_view`; put business/controller commands in `lcl_app`.
9. Keep centralized exception handling in `main`.

## View Pattern Inside The Template

The template view binds to the external data table:

```abap
lo_view->bind( changing ct_dataset = mt_dataset ).
lo_view->display( ).
```

Use `ZIF_SBCGLIB_VIEW_CALLBACKS` for double-click and column setup, and `ZIF_SBCGLIB_VIEW_CMD_HANDLER` to forward unhandled commands to the controller.

## Logging Pattern Inside The Template

Data and processor classes can own a `ZIF_SBCGLIB_LOG` instance and expose it through `get_log( )`. The controller can merge or display logs after processing. Use the `LOG` reference when adding concrete log behavior.
