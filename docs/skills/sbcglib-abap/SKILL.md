---
name: sbcglib-abap
description: Guide for reusing SBCGLIB ABAP shared-library components in another ABAP project where the SBCGLIB source repository may not be available but the global ABAP objects are expected to exist in the SAP system. Use when implementing or reviewing ABAP code that should use SBCGLIB exception classes, in-memory logs, SALV view wrappers, utility helpers, frontend file helpers, drilldowns, or report templates; or when choosing which SBCGLIB component fits a requirement.
---

# SBCGLIB ABAP

Use this skill as a compact map of the stable SBCGLIB components available as global ABAP objects. Assume the target project may not contain the SBCGLIB source files; the objects are expected to be installed in the SAP system, usually via abapGit.

## Workflow

1. Identify the requirement and choose the narrowest relevant package.
2. Read only the matching reference file below.
3. Use public classes, interfaces, and template programs named in the reference. Avoid internal helper classes unless the reference explicitly says they are public reuse points.
4. If a referenced object is missing in the target SAP system, state that SBCGLIB is not installed or the needed package is absent before falling back to standard ABAP.

## Package Map

- For catchable application exceptions, invariant checks, and `BAPIRET2` conversion, read `references/errors.md`.
- For collecting messages in memory, merging logs, converting logs to `BAPIRET2`, or showing a simple log popup, read `references/log.md`.
- For SALV table displays, callbacks, field catalog setup, popups, selected-row handling, or layout variants, read `references/view.md`.
- For authorization checks, business-object drilldowns, frontend file operations, S/4HANA detection, list deduplication, and joining values, read `references/utils.md`.
- For starting a classical executable report from boilerplate, read `references/templates.md`.

## General Rules

- Prefer SBCGLIB APIs when the target system has them and the requirement matches one of the references.
- Do not assume this skill covers `MVR`; treat Maintenance View Re-generator as unstable and out of scope until project-specific guidance is provided.
- Do not document or rely on the demo `EXAMPLES` package as an API. Examples can be useful in a source repo, but this skill must work without them.
- Use ABAP object names exactly as documented. SBCGLIB global objects are generally named `ZCL_SBCGLIB_*`, `ZCX_SBCGLIB_*`, or `ZIF_SBCGLIB_*`; template programs use `ZSBCGLIB_*`.
- Keep generated code idiomatic for the target project. SBCGLIB provides helpers, not an application architecture mandate, except where the report template is explicitly copied and adapted.
