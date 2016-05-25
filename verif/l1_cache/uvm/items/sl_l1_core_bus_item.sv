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

  constraint c_cfg_addr {
     (this.cop inside {RDNC, WRNC}) -> this.addr        inside {[cfg.min_nc_addr:cfg.max_nc_addr]};
    !(this.cop inside {RDNC, WRNC}) -> this.addr[31:13] inside {[cfg.min_addr.tag:cfg.max_addr.tag]};
		!(this.cop inside {RDNC, WRNC}) -> this.addr[12:5]  inside {[cfg.min_addr.idx:cfg.max_addr.idx]};
    !(this.cop inside {RDNC, WRNC}) -> this.addr        inside {[cfg.min_addr:cfg.max_addr]};
  }

  constraint c_size_addr {
    (this.size == 4) -> (this.addr[1:0] == 2'b0);
    (this.size == 2) -> (this.addr[0] == 1'b0);
  }

  constraint c_solve_order {
    solve this.size before this.addr;
  }

  function void pre_randomize();
  	if(this.cfg == null) `uvm_fatal("NOCFG", "User must provide cfg!")
  endfunction

endclass

`endif
