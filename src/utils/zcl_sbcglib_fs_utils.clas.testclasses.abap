class ltcl_test_utils definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods parse_path for testing.
    methods slashpath for testing.

endclass.

class ltcl_test_utils implementation.

  method parse_path.

    data lv_filename type string.
    data lv_directory type string.
    data lv_extension type string.

    zcl_sbcglib_fs_utils=>parse_path(
      exporting
        iv_path = 'c:\tmp\test.txt'
      importing
        ev_directory = lv_directory
        ev_filename  = lv_filename
        ev_extension = lv_extension ).

    cl_abap_unit_assert=>assert_equals( act = lv_directory exp = 'c:\tmp\' ).
    cl_abap_unit_assert=>assert_equals( act = lv_filename  exp = 'test' ).
    cl_abap_unit_assert=>assert_equals( act = lv_extension exp = '.txt' ).

    zcl_sbcglib_fs_utils=>parse_path(
      exporting
        iv_path = 'c:\tmp\'
      importing
        ev_directory = lv_directory
        ev_filename  = lv_filename
        ev_extension = lv_extension ).

    cl_abap_unit_assert=>assert_equals( act = lv_directory exp = 'c:\tmp\' ).
    cl_abap_unit_assert=>assert_equals( act = lv_filename  exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lv_extension exp = '' ).

    zcl_sbcglib_fs_utils=>parse_path(
      exporting
        iv_path = 'c:\tmp\test'
      importing
        ev_directory = lv_directory
        ev_filename  = lv_filename
        ev_extension = lv_extension ).

    cl_abap_unit_assert=>assert_equals( act = lv_directory exp = 'c:\tmp\' ).
    cl_abap_unit_assert=>assert_equals( act = lv_filename  exp = 'test' ).
    cl_abap_unit_assert=>assert_equals( act = lv_extension exp = '' ).

    zcl_sbcglib_fs_utils=>parse_path(
      exporting
        iv_path = 'test.txt'
      importing
        ev_directory = lv_directory
        ev_filename  = lv_filename
        ev_extension = lv_extension ).

    cl_abap_unit_assert=>assert_equals( act = lv_directory exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lv_filename  exp = 'test' ).
    cl_abap_unit_assert=>assert_equals( act = lv_extension exp = '.txt' ).

  endmethod.

  method slashpath.

    constants lc_wslash  type string value 'c:\test\'.
    constants lc_woslash type string value 'c:\test'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_fs_utils=>slashpath( lc_wslash )
      exp = lc_wslash ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_fs_utils=>slashpath( lc_woslash )
      exp = lc_wslash ).

  endmethod.

endclass.
