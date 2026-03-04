interface lif_types.

  types:
    begin of ty_selopt,
      vkorg type vkorg,
      filepath type string,
    end of ty_selopt.

  types:
    ty_order_no type c length 12,
    ty_uktzed type c length 10,
    begin of ty_data_rec,
      date type d,
      order_no type ty_order_no,
      item_text type string,
      qty type vbap-kwmeng,
      unit type vbap-meins,
      price type vbap-netpr,
      amount_net type vbap-netwr,
      amount_vat type vbap-netwr,
      curr       type vbap-waerk,
    end of ty_data_rec,
    ty_data_tab type standard table of ty_data_rec with key date order_no item_text.

endinterface.
