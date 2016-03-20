// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_cfg.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL : maksim.s.kobzar@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_L1_CFG
`define INC_L1_CFG

class l1_cfg extends uvm_object;

	sl_core_agent_cfg i_cfg;
	sl_core_agent_cfg d_cfg;
	wb_agent_cfg wb_cfg;

	`uvm_object_utils(l1_cfg)

	function new(string name = "core_agent_cfg");
		super.new(name);
	endfunction

endclass
`endif
