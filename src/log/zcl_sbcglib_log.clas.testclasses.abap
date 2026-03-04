class lx_test definition inheriting from cx_no_check.
  public section.
    interfaces if_t100_message.
    methods constructor.
endclass.

class lx_test implementation.
    method constructor.
      super->constructor( ).
      if_t100_message~t100key-msgid = '00'.
      if_t100_message~t100key-msgno = '002'.
    endmethod.
endclass.

class ltcl_test_log definition
  final
  for testing
  duration short
  risk level harmless.

  private section.

    data o type ref to zif_sbcglib_log.
    methods get_cut returning value(ro_cut) type ref to zcl_sbcglib_log.

    methods check_log for testing.
    methods merge_with for testing.
    methods size_and_clear for testing.
    methods add_str for testing.
    methods addx for testing.

    methods add_and_size for testing.
    methods log_highest_msg_type for testing.
    methods log_severity for testing.

endclass.

class ltcl_test_log implementation.

  method get_cut.
    create object ro_cut exporting i_msgid = '00'.
  endmethod.


  method add_and_size.

    data l_msg_act  type string.
    data l_msg_exp  type string.
    data ls_msg_act like line of o->messages.
    data ls_msg_exp like line of o->messages.

    o = get_cut( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = o->has_warnings( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = o->has_errors( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = o->size( ) ).

    clear ls_msg_exp.
    ls_msg_exp-msgty = 'W'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = 'Hello'.

    o->w( no = '007' v1 = 'Hello' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = o->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = o->has_warnings( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = o->has_errors( ) ).

    ls_msg_act = o->get_first_message( ).

    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

    clear ls_msg_exp.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = 'World'.

    o->e( no = '007' v1 = 'World' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = o->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = o->has_warnings( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = o->has_errors( ) ).

    read table o->messages into ls_msg_act index 2.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

  endmethod.

  method check_log.

    data l_num4     type n length 4.
    data l_chr2     type c length 2.
    data l_chr4     type c length 4.
    data l_chr10    type c length 10.
    data l_tabix    type sy-tabix.
    data l_string   type string.
    data ls_msg_act like line of o->messages.
    data ls_msg_exp like line of o->messages.

    o = get_cut( ).

    " Warning

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = o->has_warnings( ) ).

    ls_msg_exp-msgty = 'W'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = '1'.

    o->w( no = '007' v1 = '1' ).

    read table o->messages into ls_msg_act index 1.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = o->has_warnings( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = o->has_errors( ) ).

    " Error

    clear ls_msg_exp.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = '2'.

    o->e( no = '007' v1 = '2' ).
    read table o->messages into ls_msg_act index 2.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

    " Error w params

    clear ls_msg_exp.
    l_chr10 = '278'.
    l_num4  = '2015'.

    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = l_chr10.
    ls_msg_exp-msgv2 = l_num4.

    o->e( no = '007' v1 = l_chr10 v2 = l_num4 ).
    read table o->messages into ls_msg_act index 3.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

    " Add first

    clear ls_msg_exp.
    l_chr4  = 'UA99'.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '113'.
    ls_msg_exp-msgv1 = l_chr4.

    o->addm( ty = 'E' no = '113' v1 = l_chr4 first = abap_true ).
    read table o->messages into ls_msg_act index 1.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

    " Add with string

    clear ls_msg_exp.
    l_string  = 'Item'.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '007'.
    ls_msg_exp-msgv1 = l_string.

    o->addm( id = '00' ty = 'E' no = '007' v1 = l_string ).
    read table o->messages into ls_msg_act index 5.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = o->has_errors( ) ).

    " Add w 4 params

    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '378'.
    ls_msg_exp-msgv1 = l_chr10.
    ls_msg_exp-msgv2 = l_num4.
    ls_msg_exp-msgv3 = '233'.
    ls_msg_exp-msgv4 = l_num4.

    o->e( no = '378' v1 = l_chr10 v2 = l_num4 v3 = '233' v4 = l_num4 ).
    read table o->messages into ls_msg_act index 6.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

  endmethod.

  method merge_with.

    data lo_log2 like o.
    data lo_log3 like o.

    o = get_cut( ).
    lo_log2 = get_cut( ).
    lo_log3 = get_cut( ).

    o->e( no = '001' ).
    lo_log2->e( no = '002' ).
    lo_log3->w( no = '003' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( o->messages ) ).

    o->merge_with( lo_log2 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( o->messages ) ).

    o->merge_with( ii_log = lo_log3 set_severity = zif_sbcglib_log=>c_severity-error ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( o->messages ) ).

    data ls_item like line of o->messages.
    read table o->messages into ls_item index 3.
    cl_abap_unit_assert=>assert_equals(
      exp = '003'
      act = ls_item-msgno ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_item-msgty ).

  endmethod.

  method size_and_clear.

    o = get_cut( ).

    o->e( no = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = o->size( ) ).

    o->clear( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = o->size( ) ).

  endmethod.

  method add_str.

    data str type string.
    data ls_msg_act like line of o->messages.
    data ls_msg_exp like line of o->messages.

    str = repeat( val = 'A' occ = 60  ).

    o = get_cut( ).
    o->add_str( str ).

    ls_msg_act = o->get_first_message( ).
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '001'.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgv1 = repeat( val = 'A' occ = 50  ).
    ls_msg_exp-msgv2 = repeat( val = 'A' occ = 10  ).

    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

  endmethod.

  method addx.

    data lx type ref to cx_root.
    data ls_msg_act like line of o->messages.
    data ls_msg_exp like line of o->messages.

    try.
      raise exception type lx_test.
    catch cx_root into lx.
    endtry.

    o = get_cut( ).
    o->addx( lx ).

    ls_msg_act = o->get_first_message( ).
    ls_msg_exp-msgid = '00'.
    ls_msg_exp-msgno = '001'.
    ls_msg_exp-msgty = 'E'.
    ls_msg_exp-msgv1 = 'Enter a valid value'. " Test a longer and more predictable text ... repeat 60 times ...

    cl_abap_unit_assert=>assert_equals(
      exp = ls_msg_exp
      act = ls_msg_act ).

  endmethod.

  method log_highest_msg_type.

    data li_log type ref to zif_sbcglib_log.

    create object li_log type zcl_sbcglib_log.

    cl_abap_unit_assert=>assert_equals(
      exp = 'I'
      act = li_log->log_highest_msg_type( ) ).

    li_log->s( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'I'
      act = li_log->log_highest_msg_type( ) ).

    li_log->w( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'W'
      act = li_log->log_highest_msg_type( ) ).

    li_log->e( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = li_log->log_highest_msg_type( ) ).

  endmethod.

  method log_severity.

    data li_log type ref to zif_sbcglib_log.

    create object li_log type zcl_sbcglib_log.

    cl_abap_unit_assert=>assert_equals(
      exp = zif_sbcglib_log=>c_severity-none
      act = li_log->log_severity( ) ).

    li_log->s( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_sbcglib_log=>c_severity-info
      act = li_log->log_severity( ) ).

    li_log->w( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_sbcglib_log=>c_severity-warning
      act = li_log->log_severity( ) ).

    li_log->s( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_sbcglib_log=>c_severity-warning
      act = li_log->log_severity( ) ).

    li_log->e( no = '001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_sbcglib_log=>c_severity-error
      act = li_log->log_severity( ) ).

  endmethod.

endclass.
