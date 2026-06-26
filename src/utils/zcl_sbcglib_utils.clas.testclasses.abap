class ltcl_utils_test definition final
  for testing
  risk level harmless
  duration short.

  private section.

    methods get_class_text_pool for testing.

endclass.

class ltcl_utils_test implementation.

  method get_class_text_pool.

    data lo type ref to zcl_sbcglib_utils.
    data lt_texts type table_of_textpool.
    data lv_001 like line of lt_texts.

    lt_texts = zcl_sbcglib_utils=>get_class_text_pool(
      i_class_name = 'ZCL_SBCGLIB_UTILS'
      i_langu = 'E' ).

    cl_abap_unit_assert=>assert_equals(
      act = boolc( lines( lt_texts ) > 0 )
      exp = abap_true ).

    read table lt_texts into lv_001 with key key = '001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_001-entry
      exp = 'For test' ).

  endmethod.

endclass.
