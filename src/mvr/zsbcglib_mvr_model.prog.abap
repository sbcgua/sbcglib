class lcl_model definition.
  public section.

    types tr_views type range of tvdir-tabname.
    types:
      begin of ty_selection,
        devclass type range of tadir-devclass,
        tabname  type tr_views,
      end of ty_selection.

    types:
      tty_spool type standard table of bapixmspow with default key.

    types:
      begin of ty_list,
        status     type icon_d,
        tabname    type tvdir-tabname,
        area       type tvdir-area,
        ddtext     type dd02t-ddtext,
        gendate    type tvdir-gendate,
        gentime    type tvdir-gentime,
        show_log   type text25,
        spool_log  type tty_spool,
        gen_timestamp type timestamp,
        cell_type  type salv_t_int4_column,
      end of ty_list.

    types:
      tt_list type standard table of ty_list with key tabname.

    methods constructor
      importing
        is_selection type ty_selection
        it_modifiers type lif_tmv_modifier=>ty_table_of optional
      raising
        lcx_error.

    methods get_data
      returning
        value(rt_list) type tt_list
      raising
        lcx_error.

    methods regenerate
      importing
        it_sel type tt_list
      returning
        value(rt_spool) type tty_spool
      raising
        lcx_error.

  private section.
    types ty_submit_mode type c length 1.

    constants:
      begin of c_submit_mode,
        delete type ty_submit_mode value 'D',
        generate type ty_submit_mode value 'G',
      end of c_submit_mode.

    data ms_selection type ty_selection.
    data mt_list      type tt_list.
    data mt_modifiers type lif_tmv_modifier=>ty_table_of.

    methods regenerate_one
      importing
        iv_tab type ty_list-tabname
        iv_start_timestamp type timestamp
      exporting
        ev_gen_timestamp type timestamp
        et_spool type tty_spool
      raising
        lcx_error.

    methods prepare_data_after_regen
      importing
        iv_start_timestamp type timestamp
      raising
        lcx_error.

    methods process_data
      importing
        iv_start_timestamp type timestamp
      raising
        lcx_error.

    methods select_data
      raising
        lcx_error.

    class-methods select_mv_timestamp
      importing
        iv_tab type ty_list-tabname
      returning
        value(rv_ts) type timestamp.

    class-methods submit_regeneration
      importing
        it_views  type tr_views
        iv_mode   type ty_submit_mode
        is_params type pri_params
      returning
        value(rt_spool) type tty_spool
      raising
        lcx_error.

    class-methods get_print_params
      importing
        iv_no_dialog type abap_bool
      returning
        value(rs_params) type pri_params.

    class-methods open_job
      exporting
        ev_jobname  type tbtcjob-jobname
        ev_jobcount type tbtcjob-jobcount.

    class-methods close_job
      importing
        iv_jobname  type tbtcjob-jobname
        iv_jobcount type tbtcjob-jobcount.

    class-methods read_job
      importing
        iv_jobname  type tbtcjob-jobname
        iv_jobcount type tbtcjob-jobcount
      returning
        value(rv_spool_id) type tsp01-rqident.

    class-methods read_spool
      importing
        iv_spool_id type tsp01-rqident
      returning
        value(rt_spool) type tty_spool.

    class-methods format_spool
      importing
        it_spool type tty_spool
      returning
        value(rt_spool) type tty_spool.
endclass.

class lcl_model implementation.

  method constructor.
    ms_selection = is_selection.
    mt_modifiers = it_modifiers.
    select_data( ).
  endmethod.

  method prepare_data_after_regen.
    process_data( iv_start_timestamp ).
  endmethod.

  method process_data.
    data ls_cell_type type salv_s_int4_column.
    data lv_tz type tzonref-tzone.
    field-symbols <list> type ty_list.

    call function 'GET_SYSTEM_TIMEZONE'
      importing
        timezone = lv_tz.

    loop at mt_list assigning <list>.
      if <list>-spool_log is initial.
        "Log spool is not available
        clear: <list>-show_log, <list>-cell_type.
      else.
        <list>-show_log = text-104.
        ls_cell_type-columnname = 'SHOW_LOG'.
        ls_cell_type-value      = if_salv_c_cell_type=>hotspot.
        append ls_cell_type to <list>-cell_type.
      endif.
      convert time stamp <list>-gen_timestamp time zone lv_tz
        into date <list>-gendate time <list>-gentime.
      if iv_start_timestamp < <list>-gen_timestamp.
        <list>-status = icon_led_green.
      elseif iv_start_timestamp = <list>-gen_timestamp. "TMD wasn't generated
        <list>-status = icon_led_red.
      endif.
    endloop.

  endmethod.

  method select_data.

    select v~tabname v~area t~ddtext v~gendate v~gentime ##TOO_MANY_ITAB_FIELDS
      from tvdir as v
        left join dd02t as t
        on  t~tabname    = v~tabname
        and t~ddlanguage = sy-langu
      into corresponding fields of table mt_list
      where v~tabname  in ms_selection-tabname
      and   v~devclass in ms_selection-devclass.

  endmethod.

  method regenerate.

    data ls_sel type ty_list.
    data lt_spool like rt_spool.
    data lv_gen_timestamp type timestamp.
    data lv_start_timestamp type timestamp.
    field-symbols <ls_list> type ty_list.

    get time stamp field lv_start_timestamp.

    loop at it_sel into ls_sel.
      read table mt_list assigning <ls_list>
        with key tabname = ls_sel-tabname.
      if sy-subrc is not initial.
        continue.
      endif.

      <ls_list>-gen_timestamp = lv_start_timestamp. "To mark selected line
      regenerate_one(
        exporting
          iv_tab = ls_sel-tabname
          iv_start_timestamp = lv_start_timestamp
        importing
          et_spool         = <ls_list>-spool_log
          ev_gen_timestamp = <ls_list>-gen_timestamp ).
      append lines of <ls_list>-spool_log to rt_spool.
    endloop.

    "Reselect and set statuses
    prepare_data_after_regen( lv_start_timestamp ).

  endmethod.

  method regenerate_one.

    data lt_views_range type tr_views.
    data ls_params type pri_params.
    data lt_spool like et_spool.

    clear: ev_gen_timestamp, et_spool.

    ls_params = get_print_params( abap_true ).

    lcl_utils=>build_range_from_list(
      exporting
        i_data  = iv_tab
      changing
        c_range = lt_views_range ).

    "Delete TMG
    lt_spool = lcl_model=>submit_regeneration(
      iv_mode   = c_submit_mode-delete
      it_views  = lt_views_range
      is_params = ls_params ).
    lt_spool = format_spool( lt_spool ).
    append lines of lt_spool to et_spool.

    "Create TMG
    lt_spool = lcl_model=>submit_regeneration(
      iv_mode    = c_submit_mode-generate
      it_views   = lt_views_range
      is_params  = ls_params ).
    lt_spool = format_spool( lt_spool ).
    append lines of lt_spool to et_spool.

    ev_gen_timestamp = select_mv_timestamp( iv_tab ).
    if ev_gen_timestamp > iv_start_timestamp.  "check that it is recent
      data li_modifier like line of mt_modifiers.
      data lv_is_head_out type abap_bool.
      loop at mt_modifiers into li_modifier.
        if li_modifier->accepts( iv_tab ) = abap_true.
          if lv_is_head_out = abap_false.
            lv_is_head_out = abap_true.
            append '********' to et_spool.
            append 'Applying modifiers ...' to et_spool.
          endif.
          lt_spool = li_modifier->apply_adjustments( iv_tab ).
          append lines of lt_spool to et_spool.
        endif.
      endloop.
    endif.

  endmethod.

  method get_data.

    rt_list = mt_list.

  endmethod.

  method submit_regeneration.

    data lv_generate type abap_bool.
    data lv_delete   type abap_bool.
    data lv_jobname  type tbtcjob-jobname.
    data lv_jobcount type tbtcjob-jobcount.
    data lv_spool_id type tsp01-rqident.
    data lt_spool    type table of bapixmspow.

    case iv_mode.
      when c_submit_mode-generate.
        lv_generate = abap_true.
      when c_submit_mode-delete.
        lv_delete = abap_true.
      when others.
        lcx_error=>raise( 'Unexpected submit mode' ).
    endcase.

    open_job(
      importing
        ev_jobname  = lv_jobname
        ev_jobcount = lv_jobcount ).

    submit rsviewma
      with sel_view IN it_views
      with reg_only =  abap_false   "only already generated
      with new_only =  abap_false   "only not yet generated
      with all_sltd =  abap_true    "no further limitations
      with generate =  lv_generate  "generate
      with delete   =  lv_delete    "delete
      with normal   =  abap_true    "Normal mode
      with test     =  abap_false   "Test mode
      via job lv_jobname
      number  lv_jobcount
      to sap-spool without spool dynpro
      spool parameters is_params
      and return.

    close_job(
      iv_jobname  = lv_jobname
      iv_jobcount = lv_jobcount ).

    lv_spool_id = read_job(
      iv_jobname  = lv_jobname
      iv_jobcount = lv_jobcount ).

    rt_spool = read_spool( lv_spool_id ).

  endmethod.

  method get_print_params.

    data lv_valid type abap_bool.
    data ls_params type pri_params.

    call function 'GET_PRINT_PARAMETERS'
      exporting
        no_dialog      = iv_no_dialog
      importing
        valid          = lv_valid
        out_parameters = rs_params.

  endmethod.

  method open_job.

    ev_jobname = 'TMD_REGEN' && sy-datum && sy-uzeit.
    call function 'JOB_OPEN'
      exporting
        jobname  = ev_jobname
      importing
        jobcount = ev_jobcount.

  endmethod.

  method close_job.

    call function 'JOB_CLOSE'
      exporting
        jobcount  = iv_jobcount
        jobname   = iv_jobname
        strtimmed = abap_true.

  endmethod.

  method read_job.

    data ls_jobhead    type tbtcjob.
    data lt_job_read_steplist type table of tbtcstep.
    data ls_steplist   type tbtcstep.

    while ls_jobhead-status na 'AF'.
      call function 'BP_JOB_READ'
        exporting
          job_read_jobcount     = iv_jobcount
          job_read_jobname      = iv_jobname
          job_read_opcode       = '20'
        importing
          job_read_jobhead      = ls_jobhead
        tables
          job_read_steplist     = lt_job_read_steplist
        exceptions
          invalid_opcode        = 1
          job_doesnt_exist      = 2
          job_doesnt_have_steps = 3
          others                = 4.
      if ls_jobhead-status = 'F'. " F = Finished
        exit.
      elseif ls_jobhead-status = 'A'. " A = Aborted
        message e000(su) with
          'BP_JOB_READ function Aborted.'
          'Status is "' ls_jobhead-status '"'.
      endif.
    endwhile.

    read table lt_job_read_steplist into ls_steplist index 1.
    rv_spool_id = ls_steplist-listident.

  endmethod.

  method read_spool.

    call function 'RSPO_RETURN_ABAP_SPOOLJOB'
      exporting
        rqident              = iv_spool_id
      tables
        buffer               = rt_spool
      exceptions
        no_such_job          = 1
        not_abap_list        = 2
        job_contains_no_data = 3
        no_permission        = 4
        others               = 8.

  endmethod.

  method select_mv_timestamp.

    data lv_d  type d.
    data lv_t  type t.
    data lv_tz type tzonref-tzone.

    call function 'GET_SYSTEM_TIMEZONE'
      importing
        timezone = lv_tz.

    select single gendate gentime into (lv_d, lv_t)
      from tvdir
      where tabname = iv_tab.

    if sy-subrc = 0.
      convert date lv_d time lv_t into time stamp rv_ts time zone lv_tz.
    endif.

  endmethod.

  method format_spool.

    data i like line of it_spool.
    field-symbols <prev> like i.

    loop at it_spool into i.
      check i is not initial.
      if i+0(1) = space and <prev> is assigned.
        condense i.
        concatenate <prev> i into <prev> separated by space.
      else.
        append i to rt_spool assigning <prev>.
      endif.
    endloop.

  endmethod.

endclass.
