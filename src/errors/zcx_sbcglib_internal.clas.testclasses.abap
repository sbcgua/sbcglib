class ltcl_internal_error definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods raise_error for testing.
    methods assert_subrc for testing.
    methods assert_true for testing.

endclass.

class ltcl_internal_error implementation.

  method raise_error.

    data lx type ref to zcx_sbcglib_internal.
    data msg type string.

    try.
      zcx_sbcglib_internal=>raise(
        msg = 'error!'
        rc  = 'xx' ).
    catch zcx_sbcglib_internal into lx.
      cl_abap_unit_assert=>assert_equals( act = lx->rc exp = 'xx' ).
      msg = lx->get_text( ).
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'ZCX_SBCGLIB_INTERNAL->RAISE_ERROR: error!' ).
    endtry.
    cl_abap_unit_assert=>assert_not_initial( lx ).

  endmethod.

  method assert_subrc.

    data lx type ref to zcx_sbcglib_internal.

    clear sy-subrc.
    zcx_sbcglib_internal=>assert_subrc( ). " no error

    try.
      sy-subrc = 4.
      zcx_sbcglib_internal=>assert_subrc( ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_internal into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'ZCX_SBCGLIB_INTERNAL->ASSERT_SUBRC: subrc assertion failed' ).
    endtry.

  endmethod.

  method assert_true.

    data lx type ref to zcx_sbcglib_internal.

    zcx_sbcglib_internal=>assert_true( abap_true ). " no error

    try.
      zcx_sbcglib_internal=>assert_true( abap_false ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_internal into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'ZCX_SBCGLIB_INTERNAL->ASSERT_TRUE: assertion failed' ).
    endtry.

  endmethod.

endclass.
