class ltcl_test_log definition final
  for testing
  risk level harmless
  duration long.

  private section.

    methods test_display for testing.

endclass.

class ltcl_test_log implementation.

  method test_display.

    data li_log type ref to zif_sbcglib_log.


    data str type string value ' '.
    data xstr type xstring value '00A0'.
    data xstr2 type xstring value 'A000'.
    data int type i value 160.
    str = xstr.
    xstr2 = int.
    str = xstr2.

    str = cl_abap_conv_in_ce=>uccp( '00A0' ).


    field-symbols <dummy> type x.
    assign int to <dummy> casting.
    str = <dummy>.

    create object li_log type zcl_sbcglib_log
      exporting
        i_msgid = '00'
        i_name  = 'My log'.

    "different types of message
    li_log->add_str( 'Hello' ).
    li_log->e(
      no = '000'
      v1 = 'Test'
      v2 = 'error'
      v3 = 'in'
      v4 = 'new method' ).
    li_log->w(
      no = '000'
      v1 = 'Test'
      v2 = 'warning'
      v3 = 'in'
      v4 = 'new method' ).
    li_log->s(
      no = '000'
      v1 = 'Test'
      v2 = 'status'
      v3 = 'in'
      v4 = 'new method' ).

    "rows with doc_no and line_no
    li_log->addm(
      ty = 'I'
      no = '228'
      v1 = 'test'
      v2 = 'test'
      v3 = 'test' ).
    li_log->addm(
      ty = 'I'
      no = '228'
      v1 = 'test'
      v2 = 'test'
      v3 = 'test' ).

    "duplicate rows
    li_log->addm(
      ty = 'W'
      no = '000'
      v1 = 'test duplicate'
      v2 = 'test duplicate'
      v3 = 'test duplicate' ).
    li_log->addm(
      ty = 'W'
      no = '000'
      v1 = 'test duplicate'
      v2 = 'test duplicate'
      v3 = 'test duplicate' ).
    li_log->addm(
      ty = 'W'
      no = '000'
      v1 = 'test duplicate2'
      v2 = 'test duplicate2'
      v3 = 'test duplicate2' ).
    li_log->addm(
      ty = 'W'
      no = '000'
      v1 = 'test duplicate2'
      v2 = 'test duplicate2'
      v3 = 'test duplicate2' ).


    data li_extras type ref to zif_sbcglib_log.
    create object li_extras type zcl_sbcglib_log.
    li_extras->addm(
      ty = 'E'
      no = '000'
      v1 = 'set severity to none' ).

    li_log->merge_with(
      ii_log = li_extras
      set_severity = zif_sbcglib_log=>c_severity-none ).

*    create object li_extras type zcl_sbcglib_log.
*    li_extras->add(
*      ty = 'E'
*      no = '000'
*      v1 = 'supressed' ).
*
*    li_log->merge_with(
*      ii_log = li_extras
*      suppress = abap_true ).

    zcl_sbcglib_log_view=>display(
      ii_log = li_log
      iv_title = 'Test' ).

  endmethod.

endclass.
