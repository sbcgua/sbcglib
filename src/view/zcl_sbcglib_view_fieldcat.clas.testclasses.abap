class ltcl_fc_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods smoke_test for testing.

endclass.

class zcl_sbcglib_view_fieldcat definition local friends ltcl_fc_test.

class ltcl_fc_test implementation.

  method smoke_test.

    data o type ref to zcl_sbcglib_view_fieldcat.
    data f like line of o->mt_fields.

    o = zcl_sbcglib_view_fieldcat=>new(
      )->defaults( 'hide, auto_order, optimize'
      )->add( 'F1'
      )->add( f = 'F2' opts = 'hide, checkbox, ord=5, curf=waers, unit=meins, len=10'
      )->add( f = 'F3, tech' t = 'Description' opts = 'hide, hide'
      )->add( f = 'F4, col=123' " Color, Intensive, Inverted
      )->add( f = 'F5, col=abc'
      ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( o->mt_fields )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = o->globals-auto_order
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = o->globals-do_optimize
      exp = abap_true ).
    read table o->mt_default_opts transporting no fields with key table_line = 'hide'.
    cl_abap_unit_assert=>assert_subrc( ).

    read table o->mt_fields into f with key name = 'F1'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( f-opts )
      exp = 0 ).

    read table o->mt_fields into f with key name = 'F3'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = f-text
      exp = 'Description' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( f-opts )
      exp = 2 ).
    read table f-opts transporting no fields with key table_line = 'tech'.
    cl_abap_unit_assert=>assert_subrc( ).
    read table f-opts transporting no fields with key table_line = 'hide'.
    cl_abap_unit_assert=>assert_subrc( ).

    read table o->mt_fields into f with key name = 'F2'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = f-ord
      exp = 2 ). " because of auto order !
    cl_abap_unit_assert=>assert_equals(
      act = f-len
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = f-cur
      exp = 'WAERS' ).
    cl_abap_unit_assert=>assert_equals(
      act = f-unit
      exp = 'MEINS' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( f-opts )
      exp = 2 ).
    read table f-opts transporting no fields with key table_line = 'checkbox'.
    cl_abap_unit_assert=>assert_subrc( ).
    read table f-opts transporting no fields with key table_line = 'hide'.
    cl_abap_unit_assert=>assert_subrc( ).

    read table o->mt_fields into f with key name = 'F4'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = f-color-col
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = f-color-int
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = f-color-inv
      exp = 3 ).

    read table o->mt_fields into f with key name = 'F5'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_initial( f-color ).

  endmethod.

endclass.
