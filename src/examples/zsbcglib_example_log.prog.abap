report zsbcglib_example_log.

class lcl_app definition final.
  public section.
    class-methods run.
    class-methods fill_log importing ii_log type ref to zif_sbcglib_log.
endclass.

class lcl_app implementation.
  method run.

    " TODO:
    " - hide add_str message
    " - add extras or label field
    " - add show/suppress line/label, rename them ?
    " - suppress message id in string (maybe remove at all)
    " - add status text (maybe empty short text? - ** or @)

    data li_log type ref to zif_sbcglib_log.

    create object li_log type zcl_sbcglib_log
      exporting
        i_msgid = '00'
        i_name  = 'My log'.

    li_log = zcl_sbcglib_log=>new(
      i_msgid = '00'
      i_name  = 'My log' ).

    " Different types of message

    li_log->add_str( 'Hello' ).
    li_log->e(
      no = '000'
      v1 = 'Test'
      v2 = 'error' ).
    li_log->w(
      no = '000'
      v1 = 'Test'
      v2 = 'warning' ).
    li_log->s(
      no = '000'
      v1 = 'Test'
      v2 = 'success' ).

    data li_extra_log type ref to zif_sbcglib_log.
    li_extra_log = zcl_sbcglib_log=>new( ).
    li_extra_log->addm(
      ty = 'E'
      no = '000'
      v1 = 'set severity to none' ).

    li_log->merge_with(
      ii_log = li_extra_log
      set_severity = zif_sbcglib_log=>c_severity-none ).

    zcl_sbcglib_log_view=>display( li_log ).

  endmethod.

  method fill_log.
  endmethod.


endclass.

start-of-selection.
  lcl_app=>run( ).
