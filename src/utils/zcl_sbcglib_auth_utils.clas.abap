class ZCL_SBCGLIB_AUTH_UTILS definition
  public
  final
  create public.

  public section.

    types ty_actvt type tact-actvt.
    constants:
      begin of c_bkpf_buk_actvt,
        create  type ty_actvt value '01',
        change  type ty_actvt value '02',
        display type ty_actvt value '03',
        delete  type ty_actvt value '06',
        post    type ty_actvt value '10',
      end of c_bkpf_buk_actvt.

    class-methods auth_check_tcode
      importing
        !i_tcode type clike
      raising
        zcx_sbcglib_error.

    class-methods check_bkpf_buk
      importing
        i_bukrs type bukrs
        i_actvt type ty_actvt
      raising
        zcx_sbcglib_error.

    class-methods check_vbak_vko
      importing
        i_vkorg type vkorg
        i_actvt type ty_actvt
      raising
        zcx_sbcglib_error.

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SBCGLIB_AUTH_UTILS IMPLEMENTATION.


  method auth_check_tcode.

    call function 'AUTHORITY_CHECK_TCODE'
      exporting
        tcode  = i_tcode
      exceptions
        ok     = 0
        not_ok = 1
        others = 2.
    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( |No auth for { i_tcode } tcode| ).
    endif.

  endmethod.


  method check_bkpf_buk.

    authority-check object 'F_BKPF_BUK'
      id 'BUKRS' field i_bukrs
      id 'ACTVT' field i_actvt.

    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( |No auth for activity { i_actvt } in { i_bukrs } ccode| ).
    endif.

  endmethod.


  method check_vbak_vko.

    authority-check object 'V_VBAK_VKO'
      id 'VKORG' field i_vkorg
      id 'VTWEG' dummy        " distribution channel (ignored)
      id 'SPART' dummy        " division (ignored)
      id 'ACTVT' field i_actvt.

    if sy-subrc <> 0.
      zcx_sbcglib_error=>raise_simple( |No auth for activity { i_actvt } in { i_vkorg } salesorg| ).
    endif.

  endmethod.
ENDCLASS.
