// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_core_bus_item.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_L1_CORE_BUS_ITEM
`define INC_SL_L1_CORE_BUS_ITEM


class sl_l1_core_bus_item extends sl_core_bus_item;

	sl_l1_cfg cfg;

  `uvm_object_utils_begin(sl_l1_core_bus_item)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

  constraint c_addr {
  	addr[31:13] inside {[cfg.min_addr.tag:cfg.max_addr.tag]};
		addr[12:5] inside  {[cfg.min_addr.idx:cfg.max_addr.idx]};
  }

  function void pre_randomize();
  	if(this.cfg == null) `uvm_fatal("NOCFG", "User must provide cfg!")
  endfunction

endclass

`endif
