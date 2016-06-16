// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_wb_agent_cfg.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : maksim.s.kobzar@gmail.com
// ----------------------------------------------------------------------------

`ifndef INC_WB_AGENT_CFG
`define INC_WB_AGENT_CFG

class wb_agent_cfg extends uvm_object;

	bit drv_fixed_delay = 0;
	int drv_delay_max   = 20;

	`uvm_object_utils_begin(wb_agent_cfg)
		`uvm_field_int (drv_fixed_delay,   UVM_DEFAULT)
		`uvm_field_int (drv_delay_max,     UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "wb_agent_cfg");
		super.new(name);
	endfunction
endclass
`endif
