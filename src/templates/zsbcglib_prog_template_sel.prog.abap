tables: vbak.
selection-screen begin of block b1 with frame title text-001.
  parameters p_vkorg type vbak-vkorg.
selection-screen end of block b1.
selection-screen begin of block b2 with frame title text-002.
  parameters p_file type char255.
selection-screen end of block b2.

at selection-screen on value-request for p_file.
  p_file = zcl_sbcglib_fs_utils=>choose_file_dialog( ).
