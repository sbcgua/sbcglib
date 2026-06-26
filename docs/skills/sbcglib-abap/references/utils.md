# SBCGLIB Utils

Use the `UTIL` package for static helper APIs: authorization checks, common business-object drilldowns, frontend file operations, S/4HANA detection, list deduplication, and value joining.

All public APIs here are static class methods. Do not instantiate these classes.

## Authorization

Class: `ZCL_SBCGLIB_AUTH_UTILS`.

Methods raise `ZCX_SBCGLIB_ERROR` on authorization failure.

```abap
zcl_sbcglib_auth_utils=>auth_check_tcode( 'FB03' ).

zcl_sbcglib_auth_utils=>check_bkpf_buk(
  i_bukrs = lv_bukrs
  i_actvt = zcl_sbcglib_auth_utils=>c_bkpf_buk_actvt-display ).

zcl_sbcglib_auth_utils=>check_vbak_vko(
  i_vkorg = lv_vkorg
  i_actvt = zcl_sbcglib_auth_utils=>c_bkpf_buk_actvt-display ).
```

Supported checks:

- `auth_check_tcode`: transaction authorization.
- `check_bkpf_buk`: `F_BKPF_BUK` by company code/activity.
- `check_vbak_vko`: `V_VBAK_VKO` by sales organization/activity; distribution channel and division are ignored.

## Drilldowns

Class: `ZCL_SBCGLIB_DRILLDOWN`.

Use in ALV double-click handlers or command handlers. Navigation methods silently return when key fields are initial. They perform transaction authorization checks internally and raise `ZCX_SBCGLIB_ERROR` on failure.

```abap
zcl_sbcglib_drilldown=>to_fi_document(
  i_bukrs = ls_row-bukrs
  i_belnr = ls_row-belnr
  i_gjahr = ls_row-gjahr ).

zcl_sbcglib_drilldown=>to_sd_order( ls_row-vbeln ).
zcl_sbcglib_drilldown=>to_material( ls_row-matnr ).
```

Navigation methods:

- `to_bp(iv_bp_number)`: transaction BP display.
- `to_business_partner(i_bukrs, i_kunnr, i_lifnr)`: use CVI BP if available; otherwise fallback to FK03/FD03.
- `to_fi_document(i_bukrs, i_belnr, i_gjahr)`: FB03.
- `to_sd_order(i_vbeln)`: VA03.
- `to_sd_contract(i_vbeln)`: VA43.
- `to_sd_delivery(i_vbeln)`: VL03N.
- `to_sd_billing(i_vbeln)`: VF03.
- `to_sd_rebate(i_knuma)`: VBO3.
- `to_mm_order(i_ebeln)`: ME23N.
- `to_mm_contract(i_ebeln)`: ME33K or ME33L depending on `EKKO-BSTYP`.
- `to_material(i_matnr)`: MM03.

Low-level helpers:

- `call_transaction_w_auth_check(i_tcode, it_using, ...)`: call a transaction with BDC data after authorization check. Use exactly one call variant: `i_mode`, `i_skip_first_screen`, or `is_options`.
- `set_memory_parameters(it_parameters)`: set SAP memory parameter IDs from BDC-style `fnam`/`fval` entries.

## Frontend File System

Class: `ZCL_SBCGLIB_FS_UTILS`.

These methods use `CL_GUI_FRONTEND_SERVICES` and target the user's desktop. Do not use them in background jobs, HTTP/RFC handlers, or other no-GUI contexts.

```abap
lv_path = zcl_sbcglib_fs_utils=>choose_file_dialog( ).
if lv_path is not initial.
  lv_xdata = zcl_sbcglib_fs_utils=>read_file( lv_path ).
endif.
```

Methods:

- `gc_sep`: platform-specific file separator.
- `choose_file_dialog`: return selected file path or empty string.
- `choose_dir_dialog`: return selected folder path or empty string.
- `parse_path(iv_path)`: export directory, filename without extension, and extension.
- `slashpath(i_path)`: ensure trailing file separator.
- `file_exist(i_path)`: return `abap_bool`.
- `read_file(i_path)`: read binary frontend file to `xstring`; raises `ZCX_SBCGLIB_ERROR`.
- `write_file(i_path, i_data)`: write `xstring` to frontend file; raises `ZCX_SBCGLIB_ERROR`.

## Misc Utilities

Class: `ZCL_SBCGLIB_UTILS`.

Extract unique non-empty field values:

```abap
zcl_sbcglib_utils=>uniq_list_of(
  exporting
    tab = lt_items
    fld = 'BUKRS'
  importing
    ev_result = lt_bukrs ).
```

Detect S/4HANA:

```abap
if zcl_sbcglib_utils=>is_s4h( ) = abap_true.
  "S/4HANA-specific logic
endif.
```

Join values:

```abap
lv_text = zcl_sbcglib_utils=>join( it_tab = lt_values ).
lv_text = zcl_sbcglib_utils=>join( it_tab = lt_items iv_fld = 'BELNR' ).
```

`join` accepts a flat char/string table without `iv_fld`, or a structured table with a field name. Numeric text fields of ABAP type `N` are stripped of leading zeros.

Get domain values:

```abap
data lt_values type dd07v_tab.
lt_values = zcl_sbcglib_utils=>read_dom_values( i_domain_name = 'THE_DOMAIN' ).
```
