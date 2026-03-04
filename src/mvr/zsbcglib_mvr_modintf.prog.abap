interface lif_tmv_modifier.

  types ty_table_of type standard table of ref to lif_tmv_modifier with default key.
  types tty_spool   type standard table of bapixmspow with default key.

  methods accepts
    importing
      iv_tab_name type tvdir-tabname
    returning
      value(rv_yes) type abap_bool.
  methods apply_adjustments
    importing
      iv_tab_name type tvdir-tabname
    returning
      value(rt_spool) type tty_spool
    raising
      lcx_error.

endinterface.

interface lif_modifiers_list_getter.
  methods prepare_modifiers
    returning
      value(rt_modifiers) type lif_tmv_modifier=>ty_table_of
    raising
      lcx_error.
endinterface.
