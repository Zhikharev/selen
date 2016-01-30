// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_env.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CORE_ENV
`define INC_SL_CORE_ENV

class sl_core_env extends uvm_env;

  sl_core_i_agent core_i_agent;

	`uvm_component_utils(sl_core_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    core_i_agent = sl_core_i_agent::type_id::create("core_i_agent", this);
  endfunction

  function void connect_phase(uvm_phase phase);
  	super.connect_phase(phase);
  endfunction

endclass

`endif