class ltcl_error_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods simple for testing.
    methods simple_and_format for testing raising zcx_sbcglib_error.
    methods assert_subrc for testing raising zcx_sbcglib_error.
    methods assert_true for testing raising zcx_sbcglib_error.
    methods test_with_sy for testing.
    methods test_with_msg for testing.

endclass.

class ltcl_error_test implementation.

  method simple.

    data lx type ref to zcx_sbcglib_error.
    data lv_msg type string.

    lv_msg = repeat( val = 'a' occ = 120 ).

    try.
      zcx_sbcglib_error=>raise_simple(
        msg  = lv_msg
        rc   = 'ERR1'
        type = 'W' ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = lv_msg ).
      cl_abap_unit_assert=>assert_equals(
        act = lx->rc
        exp = 'ERR1' ).
      cl_abap_unit_assert=>assert_equals(
        act = lx->msg_type
        exp = 'W' ).
    endtry.

  endmethod.

  method simple_and_format.

    data lx type ref to zcx_sbcglib_error.

    try.
      zcx_sbcglib_error=>raise_simple(
        msg  = 'Hello & & & &'
        v1 = '1'
        v2 = '2'
        v3 = '3'
        v4 = '4' ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'Hello 1 2 3 4' ).
    endtry.

  endmethod.

  method assert_subrc.

    data lx type ref to zcx_sbcglib_error.

    clear sy-subrc.
    zcx_sbcglib_error=>assert_subrc( ). " no error

    try.
      sy-subrc = 4.
      zcx_sbcglib_error=>assert_subrc( ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'ZCX_SBCGLIB_ERROR->ASSERT_SUBRC: subrc assertion failed' ).
    endtry.

  endmethod.

  method assert_true.

    data lx type ref to zcx_sbcglib_error.

    zcx_sbcglib_error=>assert_true( abap_true ). " no error

    try.
      zcx_sbcglib_error=>assert_true( abap_false ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'ZCX_SBCGLIB_ERROR->ASSERT_TRUE: assertion failed' ).
    endtry.

  endmethod.

  method test_with_sy.

    data lx type ref to zcx_sbcglib_error.

    sy-msgid = '00'.
    sy-msgno = '007'.
    sy-msgv1 = 'X'.

    try.
      zcx_sbcglib_error=>raise_with_sy( ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'X is empty' ).
    endtry.

  endmethod.

  method test_with_msg.

    data lx type ref to zcx_sbcglib_error.

    try.
      zcx_sbcglib_error=>raise_w_msg(
        msgid = '00'
        msgno = '007'
        v1    = 'X' ).
      cl_abap_unit_assert=>fail( ).
    catch zcx_sbcglib_error into lx.
      cl_abap_unit_assert=>assert_equals(
        act = lx->get_text( )
        exp = 'X is empty' ).
    endtry.

  endmethod.
endclass.
