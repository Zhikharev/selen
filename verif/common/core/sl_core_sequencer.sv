// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_sequencer.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_SEQUENCER
`define INC_SL_CORE_SEQUENCER

class sl_core_sequencer extends uvm_sequencer#(sl_core_bus_item);

	sl_core_agent_cfg cfg;

	`uvm_component_utils(sl_core_sequencer)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(sl_core_agent_cfg)::get(this, "" ,"cfg", cfg))
    else `uvm_fatal("NOCFG", {"CFG must be set for: ", get_full_name(),".cfg"});
  endfunction

endclass

`endif
