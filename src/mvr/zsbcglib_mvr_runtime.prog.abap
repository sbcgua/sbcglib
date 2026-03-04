initialization.
  if lcl_utils=>is_system_customizing( ) = abap_false.
    message 'The program can only be run in customizing client' type 'E'.
  endif.

start-of-selection.
  perform main.

form main.

  data ls_selection type lcl_model=>ty_selection.
  data lo_app     type ref to lcl_app.
  data lx         type ref to cx_root.
  data li_getter  type ref to lif_modifiers_list_getter.

  ls_selection-devclass = s_devcls[].
  ls_selection-tabname  = s_tabnam[].

  try.

    perform create_modifiers_list_getter changing li_getter.

    create object lo_app
      exporting
        ii_modifiers_list_getter = li_getter
        is_selection = ls_selection.
    lo_app->run( ).

  catch cx_root into lx.
    message lx type 'S' display like 'E'.
  endtry.

endform.
