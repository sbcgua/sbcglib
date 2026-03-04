report zsbcglib_prog_template.

" SPDX-License-Identifier: Apache-2.0
" SPDX-FileCopyrightText: 2013-2026 Alexander Tsybulsky
" Project: SBCG ABAP Library (sbcglib) - https://github.com/sbcgua/sbcglib

include zsbcglib_prog_template_def.
include zsbcglib_prog_template_data.
include zsbcglib_prog_template_model1.
include zsbcglib_prog_template_model2.
include zsbcglib_prog_template_view.
include zsbcglib_prog_template_app.

include zsbcglib_prog_template_sel.

form main.

  data ls_selopt type lif_types=>ty_selopt.
  data lx_root  type ref to cx_root.
  data lx_error type ref to zcx_sbcglib_error.

  ls_selopt-vkorg = p_vkorg.
  ls_selopt-filepath = p_file.
*  ls_sel_opt-bldat = s_bldat[].

  data lo_app type ref to lcl_app.

  try.

    create object lo_app exporting i_selopt = ls_selopt.
    lo_app->run( ).

  catch zcx_sbcglib_error into lx_error.
    message lx_error type 'S' display like lx_error->msg_type.
  catch cx_root into lx_root.
    message lx_root type 'S' display like 'E'.
  endtry.

endform.

start-of-selection.
  perform main.
