class lcl_screen definition final create private.
  public section.
    class-methods read
      importing
        iv_prog type program
        iv_dynnr type dynnr
      returning
        value(ro_instance) type ref to lcl_screen
      raising
        lcx_error.
    methods save
      raising
        lcx_error.

    methods insert_customer_module
      importing
        iv_search_line type dyntxline
        it_ins_lines   type swydyflow
      raising
        lcx_error.

    methods set_container_width
      importing
        iv_width type scrcleng
      raising
        lcx_error.

    methods set_field_visible_length
      importing
        iv_field type scrfname
        iv_length type scrnvislg
      raising
        lcx_error.

  private section.
    data mv_prog type program.
    data mv_dynnr type dynnr.

    data ms_d020s type d020s.
    data ms_header               type rpy_dyhead.
    data mt_containers           type dycatt_tab.
    data mt_fields_to_containers type dyfatc_tab.
    data mt_flow_logic           type swydyflow.

    methods read_screen
      raising
        lcx_error.

    methods fix_fields_to_containers.

endclass.

class lcl_screen implementation.

  method read.

    assert iv_prog is not initial and iv_dynnr is not initial.
    create object ro_instance.
    ro_instance->mv_prog = iv_prog.
    ro_instance->mv_dynnr = iv_dynnr.
    ro_instance->read_screen( ).

  endmethod.

  method save.

    fix_fields_to_containers( ).

    call function 'RPY_DYNPRO_INSERT'
      exporting
        header                 = ms_header
        suppress_exist_checks  = abap_true
      tables
        containers             = mt_containers
        fields_to_containers   = mt_fields_to_containers
        flow_logic             = mt_flow_logic
      exceptions
        cancelled              = 1
        already_exists         = 2
        program_not_exists     = 3
        not_executed           = 4
        missing_required_field = 5
        illegal_field_value    = 6
        field_not_allowed      = 7
        not_generated          = 8
        illegal_field_position = 9
        others                 = 10.

    if sy-subrc <> 0.
      lcx_error=>raise( |Error saving screen { mv_prog }/{ mv_dynnr } [{ sy-subrc }]| ).
    endif.

  endmethod.

  method read_screen.

    data lt_d020s like table of ms_d020s.

    call function 'RS_SCREEN_LIST'
      exporting
        progname  = mv_prog
        dynnr     = mv_dynnr
      tables
        dynpros   = lt_d020s
      exceptions
        not_found = 1
        others    = 2.

    if sy-subrc <> 0.
      lcx_error=>raise( |Error reading screen { mv_prog }/{ mv_dynnr }| ).
    endif.

    read table lt_d020s into ms_d020s index 1.
    assert sy-subrc = 0.

    call function 'RPY_DYNPRO_READ'
      exporting
        progname             = mv_prog
        dynnr                = ms_d020s-dnum
      importing
        header               = ms_header
      tables
        containers           = mt_containers
        fields_to_containers = mt_fields_to_containers
        flow_logic           = mt_flow_logic
      exceptions
        cancelled            = 1
        not_found            = 2
        permission_error     = 3
        others               = 4.

    if sy-subrc <> 0.
      lcx_error=>raise( |Error reading screen { mv_prog }/{ mv_dynnr }| ).
    endif.

  endmethod.

  method fix_fields_to_containers.

    " source: abapgit

    constants lc_force_off type c length 1 value '/'.
    field-symbols <field> like line of mt_fields_to_containers.

    loop at mt_fields_to_containers assigning <field>.

      " if the DDIC element has a PARAMETER_ID and the flag "from_dict" is active
      " the import will enable the SET-/GET_PARAM flag. In this case: "force off"
      if <field>-param_id is not initial and <field>-from_dict = abap_true.
        if <field>-set_param is initial.
          <field>-set_param = lc_force_off.
        endif.
        if <field>-get_param is initial.
          <field>-get_param = lc_force_off.
        endif.
      endif.

      " If the previous conditions are met the value 'F' will be taken over
      " during de-serialization potentially overlapping other fields in the screen,
      " we set the tag to the correct value 'X'
        if <field>-type = 'CHECK'
            and <field>-from_dict = abap_true
            and <field>-text is initial
            and <field>-modific is initial.
          <field>-modific = 'X'.
        endif.

        if <field>-foreignkey is initial.
          <field>-foreignkey = lc_force_off.
        endif.

    endloop.

  endmethod.

  method set_container_width.

    field-symbols <cont> like line of mt_containers.
    read table mt_containers assigning <cont> with key type = 'TABLE_CTRL'.
    <cont>-length = iv_width.
    ms_header-columns = iv_width + 1.

  endmethod.

  method set_field_visible_length.

    field-symbols <f> like line of mt_fields_to_containers.

    read table mt_fields_to_containers assigning <f> with key name = iv_field.
    if sy-subrc <> 0.
      lcx_error=>raise( |{ mv_prog }/{ mv_dynnr }/{ iv_field } field not found| ).
    endif.

    <f>-vislength = iv_length.

  endmethod.

  method insert_customer_module.
    data lv_tabix type sy-tabix.
    loop at mt_flow_logic transporting no fields
      where line cp iv_search_line.
    endloop.
    if sy-subrc is initial.
      lv_tabix = sy-tabix.
      add 1 to lv_tabix.
      insert lines of it_ins_lines into mt_flow_logic index lv_tabix.
    endif.
  endmethod.

endclass.

**********************************************************************

class lcl_utils definition final.
  public section.
    class-methods is_system_customizing
      returning
        value(rv_yesno) type abap_bool.
    class-methods split
      importing
        iv_str type string
      returning
        value(rt_str) type string_table.
    class-methods build_range_from_list
      importing
        !i_data   type any
        !i_option type char2 optional
        !i_sign   type char1 optional
        !i_fld    type abap_compname optional
      changing
        value(c_range) type standard table.
endclass.

class lcl_utils implementation.

  method is_system_customizing.

    data lv_role type t000-cccategory.

    call function 'TR_SYS_PARAMS'
      importing
        system_client_role = lv_role
      exceptions
        no_systemname      = 1
        no_systemtype      = 2
        others             = 3.
    if sy-subrc is initial and lv_role = 'C'. "Customizing
      rv_yesno = abap_true.
    endif.

  endmethod.

  method split.

    split iv_str at |\n| into table rt_str.
    delete rt_str where table_line is initial.

  endmethod.

  method build_range_from_list.

    field-symbols: <field>      type any,
                   <src>        type any,
                   <list_line>  type any,
                   <range_line> type any,
                   <table>      type any table.

    data lo_type_descr type ref to cl_abap_typedescr.
    data lv_fld_name like i_fld.

    lo_type_descr = cl_abap_typedescr=>describe_by_data( i_data ).

    case lo_type_descr->kind.
      when 'T'. " Table
        assign i_data to <table>.
        lv_fld_name = to_upper( i_fld ).

        loop at <table> assigning <list_line>.
          append initial line to c_range assigning <range_line>.
          assign component 'SIGN' of structure <range_line> to <field>.
          <field> = 'I'.
          assign component 'OPTION' of structure <range_line> to <field>.
          <field> = 'EQ'.
          assign component 'LOW' of structure <range_line> to <field>.
          if lv_fld_name is initial.
            <field> = <list_line>.
          else.
            assign component lv_fld_name of structure <list_line> to <src>.
            <field> = <src>.
          endif.
        endloop.

        sort c_range.
        delete adjacent duplicates from c_range.

      when 'S'. "Structure
        assign i_data to <list_line>.
        lv_fld_name = to_upper( i_fld ).

        append initial line to c_range assigning <range_line>.
        assign component 'SIGN' of structure <range_line> to <field>.
        <field> = 'I'.
        assign component 'OPTION' of structure <range_line> to <field>.
        <field> = 'EQ'.
        assign component 'LOW' of structure <range_line> to <field>.
        if lv_fld_name is initial.
          <field> = <list_line>.
        else.
          assign component lv_fld_name of structure <list_line> to <src>.
          <field> = <src>.
        endif.

      when 'E'. "Data element
        append initial line to c_range assigning <range_line>.
        assign component 'SIGN' of structure <range_line> to <field>.
        if i_sign is initial.
          <field> = 'I'.
        else.
          <field> = i_sign.
        endif.
        assign component 'OPTION' of structure <range_line> to <field>.
        if i_option is initial.
          <field> = 'EQ'.
        else.
          <field> = i_option.
        endif.
        assign component 'LOW' of structure <range_line> to <field>.
        <field> = i_data.
     endcase.

  endmethod.

endclass.
