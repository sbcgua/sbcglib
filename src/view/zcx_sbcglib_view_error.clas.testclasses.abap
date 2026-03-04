class lcl_test_exception definition final
  for testing
  duration short
  risk level harmless.

  private section.

    methods test_raise for testing.

endclass.

class lcl_test_exception implementation.

  method test_raise.

    data lx type ref to zcx_sbcglib_view_error.
    data lv_msg type string.

    lv_msg = repeat( val = 'a' occ = 120 ).

    try.
      zcx_sbcglib_view_error=>raise( lv_msg ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_view_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = lv_msg ).
    endtry.

  endmethod.

endclass.
