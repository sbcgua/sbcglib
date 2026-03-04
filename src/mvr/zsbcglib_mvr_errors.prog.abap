class lcx_error definition final inheriting from cx_static_check.
  public section.
    interfaces if_t100_message.
    data v1 type symsgv read-only.
    data v2 type symsgv read-only.
    data v3 type symsgv read-only.
    data v4 type symsgv read-only.

    class-methods raise
      importing
        m type csequence
      raising
        lcx_error.
    methods constructor
      importing
        v1 type symsgv
        v2 type symsgv
        v3 type symsgv
        v4 type symsgv.
endclass.

class lcx_error implementation.

  method constructor.
    super->constructor( ).
    me->v1 = v1.
    me->v2 = v2.
    me->v3 = v3.
    me->v4 = v4.
    if_t100_message~t100key-msgid = '00'.
    if_t100_message~t100key-msgno = '001'.
    if_t100_message~t100key-attr1 = 'V1'.
    if_t100_message~t100key-attr2 = 'V2'.
    if_t100_message~t100key-attr3 = 'V3'.
    if_t100_message~t100key-attr4 = 'V4'.
  endmethod.

  method raise.

    data:
      begin of ls_split,
        v1 like v1,
        v2 like v1,
        v3 like v1,
        v4 like v1,
      end of ls_split.

    ls_split = m.

    raise exception type lcx_error
      exporting
        v1 = ls_split-v1
        v2 = ls_split-v2
        v3 = ls_split-v3
        v4 = ls_split-v4.

  endmethod.
endclass.
