class ZCL_SBCGLIB_FS_UTILS definition
  public
  final
  create public.

  public section.

    class-data:
      gc_sep type c length 1 read-only.

    class-methods class_constructor.
    class-methods choose_file_dialog
      returning
        value(rv_path) type string.
    class-methods choose_dir_dialog
      returning
        value(rv_path) type string.
    class-methods parse_path
      importing
        iv_path type string
      exporting
        ev_directory type string
        ev_filename type string
        ev_extension type string.
    class-methods slashpath
      importing
        i_path type csequence
      returning
        value(r_path) type string.

    class-methods file_exist
      importing
        i_path type string
      returning
        value(rv_yes) type abap_bool.

    class-methods write_file
      importing
        i_path type string
        i_data type xstring
      raising
        zcx_sbcglib_error.

    class-methods read_file
      importing
        i_path type string
      returning
        value(rv_data) type xstring
      raising
        zcx_sbcglib_error.

    " TODO, see ZCL_W3MIME_FS, ZCL_UA_VAT_FS_ACCESSOR

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SBCGLIB_FS_UTILS IMPLEMENTATION.


  method choose_dir_dialog.

    data l_str type string.

    cl_gui_frontend_services=>directory_browse(
      changing
        selected_folder      = l_str
      exceptions
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        others               = 4 ).

    if sy-subrc = 0.
      rv_path = l_str.
    endif.

  endmethod.


  method choose_file_dialog.

    data lt_files type filetable.
    data lv_rc    type i.
    data lv_uact  type i.

    field-symbols <file> like line of lt_files.

    cl_gui_frontend_services=>file_open_dialog(
      changing
        file_table  = lt_files
        rc          = lv_rc
        user_action = lv_uact
      exceptions others = 4 ).

    if sy-subrc > 0 or lv_uact <> cl_gui_frontend_services=>action_ok.
      return. " Empty value
    endif.

    read table lt_files assigning <file> index 1.
    if sy-subrc = 0.
      rv_path = <file>-filename.
    endif.

  endmethod.


  method class_constructor.

    cl_gui_frontend_services=>get_file_separator( changing file_separator = gc_sep exceptions others = 4 ).
    if sy-subrc <> 0.
      gc_sep = '\'. " Assume windows (eclipse ???)
    endif.

  endmethod.


  method file_exist.

    cl_gui_frontend_services=>file_exist(
      exporting
        file                 = i_path
      receiving
        result               = rv_yes
      exceptions
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        not_supported_by_gui = 4
        others               = 5 ).

    if sy-subrc <> 0.
      rv_yes = abap_false. " Force in case of error just incase
    endif.

  endmethod.


  method parse_path.

    data lv_offs type i.

    clear: ev_filename, ev_extension, ev_directory.

    if strlen( iv_path ) = 0.
      return.
    endif.

    find first occurrence of gc_sep in reverse( iv_path ) match offset lv_offs.

    if sy-subrc = 0.
      lv_offs      = strlen( iv_path ) - lv_offs.
      ev_directory = substring( val = iv_path len = lv_offs ).
      ev_filename  = substring( val = iv_path off = lv_offs ).
    else.
      ev_filename  = iv_path.
    endif.

    find first occurrence of '.' in reverse( ev_filename ) match offset lv_offs.

    if sy-subrc = 0.
      lv_offs      = strlen( ev_filename ) - lv_offs - 1.
      ev_extension = substring( val = ev_filename off = lv_offs ).
      ev_filename  = substring( val = ev_filename len = lv_offs ).
    endif.

  endmethod.


  method read_file.

    data lt_xdata type lvc_t_mime.
    data lv_size type i.

    cl_gui_frontend_services=>gui_upload(
      exporting
        filename                = i_path
        filetype                = 'BIN'
      importing
        filelength              = lv_size
      changing
        data_tab                = lt_xdata
      exceptions
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        others                  = 19 ).
    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( |Could not read file [RC={ sy-subrc }]| ).
    endif.

    " see also cl_bcs_convert=>solix_to_xstring( )

    call function 'SCMS_BINARY_TO_XSTRING'
      exporting
        input_length = lv_size
      importing
        buffer       = rv_data
      tables
        binary_tab   = lt_xdata.

  endmethod.


  method slashpath.

    data l_len type i.

    r_path = i_path.
    l_len  = strlen( i_path ).

    if l_len > 1.
      l_len = l_len - 1.
      if i_path+l_len(1) <> gc_sep.
        concatenate i_path gc_sep into r_path.
      endif.
    endif.

  endmethod.


  method write_file.

    data lv_size   type i.
    data ls_textid type scx_t100key.
    data lt_bin    type sdokcntbins.

    call function 'SCMS_XSTRING_TO_BINARY'
      exporting
        buffer        = i_data
      importing
        output_length = lv_size
      tables
        binary_tab    = lt_bin.

    cl_gui_frontend_services=>gui_download(
      exporting
        bin_filesize            = lv_size
        filename                = i_path
        filetype                = 'BIN'
      changing
        data_tab                = lt_bin
      exceptions
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        others                  = 24 ).

    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( |Could not write file [RC={ sy-subrc }]| ).
    endif.

  endmethod.
ENDCLASS.
