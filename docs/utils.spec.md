# "Utils" package functionality

This document describes public functionality of the SBCGLIB `utils` package.

## Reuse summary

- Use this package for common static helpers: authorization checks, business-object drilldowns, frontend file operations, S/4HANA detection, list deduplication, and string joining.
- Do not use frontend file utilities in background, HTTP, RFC, or other no-GUI contexts; they are based on `CL_GUI_FRONTEND_SERVICES`.
- Main entry points: `ZCL_SBCGLIB_AUTH_UTILS`, `ZCL_SBCGLIB_DRILLDOWN`, `ZCL_SBCGLIB_FS_UTILS`, and `ZCL_SBCGLIB_UTILS`.
- Dependencies: several helpers raise `ZCX_SBCGLIB_ERROR` or `ZCX_SBCGLIB_INTERNAL`, so the `ERRORS` package is expected.
- Agent note: all public utility APIs are static class methods; instantiate none of these classes.

## Public functionality

The package is a collection of frequent code patterns of different nature that are worth unifying and simplifying. It includes:

- `ZCL_SBCGLIB_AUTH_UTILS` - typical authorization checks, raises `ZCX_SBCGLIB_ERROR` on failure
- `ZCL_SBCGLIB_DRILLDOWN` - static methods to navigate into widespread business objects like vendors, customers, FI documents, or SD/MM objects; intended for use in ALV double-click handlers
- `ZCL_SBCGLIB_FS_UTILS` - user desktop (frontend) file system utilities
- `ZCL_SBCGLIB_UTILS` - miscellaneous frequently used ABAP patterns

All classes use only static (class) methods. Navigation methods in `ZCL_SBCGLIB_DRILLDOWN` perform auth checks internally and raise `ZCX_SBCGLIB_ERROR` on failure.

## ZCL_SBCGLIB_AUTH_UTILS

- `auth_check_tcode` - checks authorization to run a transaction, raises on failure
- `check_bkpf_buk` - checks access to a company code (bukrs)
- `check_vbak_vko` - checks access to a sales organization (vkorg)

## ZCL_SBCGLIB_DRILLDOWN

All methods are static. Navigation silently returns when key fields are initial (no action).

- `to_bp(iv_bp_number)` - opens Business Partner master data display (transaction BP) by BP number
- `to_business_partner(i_bukrs, i_kunnr, i_lifnr)` - navigates to a business partner by company code and customer or vendor number; checks CVI link tables first and uses `to_bp` if a BP exists, otherwise falls back to FK03 (vendor) or FD03 (customer) via BDC
- `to_fi_document(i_bukrs, i_belnr, i_gjahr)` - opens a FI accounting document in FB03
- `to_sd_order(i_vbeln)` - opens a SD sales order in VA03
- `to_sd_contract(i_vbeln)` - opens a SD contract in VA43
- `to_sd_delivery(i_vbeln)` - opens an outbound delivery in VL03N
- `to_sd_billing(i_vbeln)` - opens a billing/invoice document in VF03
- `to_sd_rebate(i_knuma)` - opens a SD rebate agreement in VBO3
- `to_mm_order(i_ebeln)` - opens a purchase order in ME23N
- `to_mm_contract(i_ebeln)` - opens a MM contract (ME33K) or scheduling agreement (ME33L); determines type by reading EKKO-BSTYP
- `to_material(i_matnr)` - opens a material master in MM03
- `call_transaction_w_auth_check(i_tcode, it_using, ...)` - low-level helper used by the navigation methods; calls a transaction with BDC data after an auth check; supports three call variants: `i_mode` (E/N/A), `i_skip_first_screen`, or `is_options` (CTU_PARAMS); returns collected BDC messages
- `set_memory_parameters(it_parameters)` - helper that sets memory parameters before invoking a transaction. Used internally but can be useful to call other transactions.

## ZCL_SBCGLIB_FS_UTILS

All operations target the user's frontend (desktop) via `CL_GUI_FRONTEND_SERVICES`. The class uses `gc_sep` as a platform-specific file separator, initialized automatically at class load.

- `gc_sep` - read-only file separator character (`\` on Windows), initialized via `class_constructor`
- `choose_file_dialog` - opens a file-open dialog on the user's desktop; returns the selected file path or empty string if cancelled
- `choose_dir_dialog` - opens a directory browse dialog; returns the selected folder path or empty string if cancelled
- `parse_path(iv_path)` - splits a full path into `ev_directory`, `ev_filename` (without extension), and `ev_extension`
- `slashpath(i_path)` - ensures the path ends with `gc_sep`; useful when building paths by concatenation
- `file_exist(i_path)` - returns `abap_bool` indicating whether the file exists on the frontend
- `read_file(i_path)` - reads a binary file from the frontend into an `xstring`; raises `ZCX_SBCGLIB_ERROR` on failure
- `write_file(i_path, i_data)` - writes `xstring` binary data to a file on the frontend; raises `ZCX_SBCGLIB_ERROR` on failure

## ZCL_SBCGLIB_UTILS

- `uniq_list_of(tab, fld)` - extracts unique non-empty values of a named field from any internal table; returns a sorted, deduplicated flat table
- `is_s4h` - detects whether the current system is S/4HANA by reflecting on `CL_COS_UTILITIES` at runtime; returns `abap_bool`
- `join(it_tab, iv_fld)` - joins table values into a comma-separated string; accepts a flat char/string table (omit `iv_fld`) or a structured table with a field name; numeric fields (type N) are stripped of leading zeros
- `read_dom_values(i_domain_name,i_langu)` - read the domain values in the given language (defaulted to `sy-langu` if not supplied)