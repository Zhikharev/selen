// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_agent_cfg.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_AGENT_CFG
`define INC_SL_CORE_AGENT_CFG

class sl_core_agent_cfg extends uvm_object;

	core_port_t port;

	`uvm_object_utils_begin(sl_core_agent_cfg)
		`uvm_field_enum(core_port_t, port, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "core_agent_cfg");
		super.new(name);
	endfunction
endclass
`endif
