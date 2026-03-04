class ltcl_err_utils definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods format_message for testing.

endclass.

class ltcl_err_utils implementation.


  method format_message.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_err_utils=>format_message(
        msg = 'Hello &1' )
      exp = 'Hello &1' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_err_utils=>format_message(
        msg = 'Hello &1'
        v1  = 'world' )
      exp = 'Hello world' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_err_utils=>format_message(
        msg = 'Hello &'
        v1  = 'world' )
      exp = 'Hello world' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_err_utils=>format_message(
        msg = 'Hello &2 &1 &3 &4'
        v1  = '1'
        v2  = '2'
        v3  = '3'
        v4  = '4' )
      exp = 'Hello 2 1 3 4' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_sbcglib_err_utils=>format_message(
        msg = 'Hello & & & &'
        v1  = '1'
        v2  = '2'
        v3  = '3'
        v4  = '4' )
      exp = 'Hello 1 2 3 4' ).

  endmethod.

endclass.
