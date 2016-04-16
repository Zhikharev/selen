// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_global_cfg.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_GLOBAL_CFG
`define INC_SL_GLOBAL_CFG

class sl_global_cfg extends uvm_object;

	sl_core_agent_cfg i_cfg;
	sl_core_agent_cfg d_cfg;
	wb_agent_cfg wb_cfg;

	rand sl_l1_cfg li_cfg;
	rand sl_l1_cfg ld_cfg;

	`uvm_object_utils_begin(sl_global_cfg)
		`uvm_field_object(li_cfg, UVM_DEFAULT)
		`uvm_field_object(ld_cfg, UVM_DEFAULT)
	`uvm_object_utils_end

	constraint c_independent_addr_space {
		li_cfg.min_addr >= 32'h0000_0000;
		li_cfg.max_addr <= 32'h7fff_ffff;
		ld_cfg.min_addr >= 32'h8000_0000;
		ld_cfg.max_addr <= 32'hffff_ffff;
	}

	function new(string name = "sl_global_cfg");
		super.new(name);
		i_cfg = sl_core_agent_cfg::type_id::create("i_cfg");
		i_cfg.port = INSTR;
		d_cfg = sl_core_agent_cfg::type_id::create("d_cfg");
		d_cfg.port = DATA;
		wb_cfg = wb_agent_cfg::type_id::create("wb_cfg");
		li_cfg = sl_l1_cfg::type_id::create("li_cfg");
		ld_cfg = sl_l1_cfg::type_id::create("ld_cfg");
	endfunction

endclass
`endif
