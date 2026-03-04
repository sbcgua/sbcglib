program zsbcglib_mvr_example.

include zsbcglib_mvr_errors.
include zsbcglib_mvr_modintf.
include zsbcglib_mvr_helpers.
include zsbcglib_mvr_modifiers.

**********************************************************************

class lcl_modifier_tc_ver_v definition final.
  public section.
    interfaces lif_tmv_modifier.

  private section.

    methods get_code_to_insert
      returning
        value(rt_code) type swydyflow.

endclass.

class lcl_modifier_tc_ver_v implementation.

  method get_code_to_insert.
    append ' MODULE CUSTOMER_LIST_EDIT.' to rt_code.
  endmethod.

  method lif_tmv_modifier~accepts.
    rv_yes = boolc( iv_tab_name = 'ZUA_VAT_TC_VER_V' ).
  endmethod.

  method lif_tmv_modifier~apply_adjustments.

    if lif_tmv_modifier~accepts( iv_tab_name ) = abap_false.
      lcx_error=>raise( |Unexpected view '{ iv_tab_name }'| ).
    endif.

    data ls_tvdir type tvdir.
    data lv_main_prog_name type program.
    data lo_scr type ref to lcl_screen.

    ls_tvdir = lcl_modifier_utils=>read_tvdir( iv_tab_name ).
    lv_main_prog_name = lcl_modifier_utils=>get_fm_main_prog( ls_tvdir-area ).

    lo_scr = lcl_screen=>read(
      iv_prog  = lv_main_prog_name
      iv_dynnr = |{ ls_tvdir-liste }| ).
    lo_scr->insert_customer_module(
      iv_search_line = '*MODULE LISTE_INITIALISIEREN*'
      it_ins_lines   = get_code_to_insert( ) ).

    lo_scr->save( ).

    append '- insert_customer_module applied' to rt_spool.

  endmethod.

endclass.

class lcl_modifier_list definition final.
  public section.
    interfaces lif_modifiers_list_getter.
endclass.

class lcl_modifier_list implementation.

  method lif_modifiers_list_getter~prepare_modifiers.

    data li_m like line of rt_modifiers.

    create object li_m type lcl_modifier_width
      exporting
        it_config = lcl_utils=>split(
          |ZUA_VAT_SETTINGS:199\n| &&
          |ZUA_VAT_TC_VER_V:199\n| &&
          |ZUA_VAT_TC_V:199\n| &&
          |ZUA_VAT_EX_CODES:199\n| &&
          |ZUA_VAT_EX_RSNS:199\n| &&
          |ZUA_VAT_USER_MD:199\n| &&

          |ZUA_VAT_EVENT:199\n| &&
          |ZUA_VAT_VV_HEAD:199\n| &&
          |ZUA_VAT_VV_RELAT:199\n| &&
          |ZUA_VAT_VV_IMPL:199\n| &&
          |ZUA_VAT_VV_LINES:199\n|
        ).
    append li_m to rt_modifiers.

    create object li_m type lcl_modifier_field_vislen
      exporting
        it_config = lcl_utils=>split(
          |ZUA_VAT_USER_MD:ACCOUNTANT:20\n| &&

          |ZUA_VAT_SETTINGS:ACCOUNTANT:20\n| &&

          |ZUA_VAT_EX_CODES:EXCODE_DESCR:40\n| &&

          |ZUA_VAT_EX_RSNS:LEGAL_REASON:40\n| &&
          |ZUA_VAT_EX_RSNS:EXRSN_DESCR:40\n| &&

          |ZUA_VAT_TC_V:MWART:15\n| &&
          |ZUA_VAT_TC_V:TEXT1:25\n| &&

          |ZUA_VAT_TC_VER_V:MWART:10\n| &&
          |ZUA_VAT_TC_VER_V:TEXT1:20\n| &&
          |ZUA_VAT_TC_VER_V:SCENARIO:15\n|
        ).
    append li_m to rt_modifiers.

    create object li_m type lcl_modifier_tc_ver_v.
    append li_m to rt_modifiers.

  endmethod.

endclass.

form create_modifiers_list_getter changing ci_getter.
  create object ci_getter type lcl_modifier_list.
endform.

include zsbcglib_mvr_model.
include zsbcglib_mvr_view.
include zsbcglib_mvr_app_base.
include zsbcglib_mvr_selscr.
include zsbcglib_mvr_runtime.
