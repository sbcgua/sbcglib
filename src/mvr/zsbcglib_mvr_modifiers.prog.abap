class lcl_modifier_utils definition abstract.
  public section.

    class-methods read_tvdir
      importing
        iv_view_name type tvdir-tabname
      returning
        value(rs_tvdir) type tvdir
      raising
        lcx_error.

    class-methods get_fm_main_prog
      importing
        iv_fugr type tvdir-area
      returning
        value(rv_program) type program
      raising
        lcx_error.

endclass.

class lcl_modifier_utils implementation.
  method read_tvdir.

    select single * into rs_tvdir
      from tvdir
      where tabname = iv_view_name.
    if sy-subrc <> 0.
      lcx_error=>raise( |TVDIR entry for { iv_view_name } was not found| ).
    endif.
  endmethod.

  method get_fm_main_prog.

    data lv_namespace type rs38l-namespace.
    data lv_group     type rs38l-area.

    call function 'FUNCTION_INCLUDE_SPLIT'
      exporting
        complete_area                = iv_fugr
      importing
        namespace                    = lv_namespace
        group                        = lv_group
      exceptions
        include_not_exists           = 1
        group_not_exists             = 2
        no_selections                = 3
        no_function_include          = 4
        no_function_pool             = 5
        delimiter_wrong_position     = 6
        no_customer_function_group   = 7
        no_customer_function_include = 8
        reserved_name_customer       = 9
        namespace_too_long           = 10
        area_length_error            = 11
        others                       = 12.
    if sy-subrc <> 0.
      lcx_error=>raise( |Cannot find prog name for { iv_fugr } fugr| ).
    endif.

    concatenate lv_namespace 'SAPL' lv_group into rv_program.

  endmethod.

endclass.

**********************************************************************

class lcl_modifier_width definition final.
  public section.
    interfaces lif_tmv_modifier.
    types:
      begin of ty_config,
        tab_name type tvdir-tabname,
        width    type scrcleng,
      end of ty_config.
    methods constructor
      importing
        it_config type string_table
      raising
        lcx_error.
  private section.
    data mt_config type standard table of ty_config.
    methods parse_config
      importing
        iv_str type string
      returning
        value(rs_conf) type ty_config
      raising
        lcx_error.
endclass.

class lcl_modifier_width implementation.

  method constructor.

    field-symbols <c> like line of it_config.
    loop at it_config assigning <c>.
      append parse_config( <c> ) to mt_config.
    endloop.

  endmethod.

  method parse_config.

    split iv_str at ':' into rs_conf-tab_name rs_conf-width.

    if rs_conf-tab_name is initial or rs_conf-width is initial.
      lcx_error=>raise( |wrong config: { iv_str }| ).
    endif.

  endmethod.

  method lif_tmv_modifier~accepts.
    read table mt_config transporting no fields with key tab_name = iv_tab_name.
    rv_yes = boolc( sy-subrc = 0 ).
  endmethod.

  method lif_tmv_modifier~apply_adjustments.

    if lif_tmv_modifier~accepts( iv_tab_name ) = abap_false.
      lcx_error=>raise( |Unexpected view '{ iv_tab_name }'| ).
    endif.

    data ls_tvdir type tvdir.
    data lv_main_prog_name type program.
    data lo_scr type ref to lcl_screen.
    data ls_config like line of mt_config.

    read table mt_config into ls_config with key tab_name = iv_tab_name.
    assert sy-subrc = 0.

    ls_tvdir = lcl_modifier_utils=>read_tvdir( ls_config-tab_name ).
    lv_main_prog_name = lcl_modifier_utils=>get_fm_main_prog( ls_tvdir-area ).
    lo_scr = lcl_screen=>read(
      iv_prog  = lv_main_prog_name
      iv_dynnr = |{ ls_tvdir-liste }| ).
    lo_scr->set_container_width( ls_config-width ).
    lo_scr->save( ).

    append '- set_container_width applied' to rt_spool.

  endmethod.

endclass.


**********************************************************************

class lcl_modifier_field_vislen definition final.
  public section.
    interfaces lif_tmv_modifier.

    types:
      begin of ty_config,
        tab_name type tvdir-tabname,
        field type scrfname,
        length type scrnvislg,
      end of ty_config.

    methods constructor
      importing
        it_config type string_table
      raising
        lcx_error.

  private section.
    data mt_config type standard table of ty_config.
    methods parse_config
      importing
        iv_str type string
      returning
        value(rs_conf) type ty_config
      raising
        lcx_error.

endclass.

class lcl_modifier_field_vislen implementation.

  method constructor.

    field-symbols <c> like line of it_config.
    loop at it_config assigning <c>.
      append parse_config( <c> ) to mt_config.
    endloop.

  endmethod.

  method parse_config.

    split iv_str at ':' into rs_conf-tab_name rs_conf-field rs_conf-length.

    if rs_conf-tab_name is initial or rs_conf-field is initial or rs_conf-length is initial.
      lcx_error=>raise( |wrong config: { iv_str }| ).
    endif.

  endmethod.

  method lif_tmv_modifier~accepts.
    read table mt_config transporting no fields with key tab_name = iv_tab_name.
    rv_yes = boolc( sy-subrc = 0 ).
  endmethod.

  method lif_tmv_modifier~apply_adjustments.

    if lif_tmv_modifier~accepts( iv_tab_name ) = abap_false.
      lcx_error=>raise( |Unexpected view '{ iv_tab_name }'| ).
    endif.

    data ls_tvdir type tvdir.
    data lv_main_prog_name type program.
    data lo_scr type ref to lcl_screen.
    data ls_config like line of mt_config.

    ls_tvdir = lcl_modifier_utils=>read_tvdir( iv_tab_name ).
    lv_main_prog_name = lcl_modifier_utils=>get_fm_main_prog( ls_tvdir-area ).
    lo_scr = lcl_screen=>read(
      iv_prog  = lv_main_prog_name
      iv_dynnr = |{ ls_tvdir-liste }| ).

    loop at mt_config into ls_config where tab_name = iv_tab_name.
      lo_scr->set_field_visible_length(
        iv_field  = |*{ iv_tab_name }-{ ls_config-field }|
        iv_length = ls_config-length ).
      lo_scr->set_field_visible_length(
        iv_field  = |{ iv_tab_name }-{ ls_config-field }|
        iv_length = ls_config-length ).
    endloop.

    lo_scr->save( ).

    append '- adj_field_visible_length applied' to rt_spool.

  endmethod.

endclass.
