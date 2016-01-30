// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_i_agent.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CORE_I_AGENT
`define INC_SL_CORE_I_AGENT

typedef uvm_sequencer#(rv32_transaction) sl_core_seqr;

class sl_core_i_agent extends uvm_agent;

	sl_core_i_drv driver;
	sl_core_seqr  sequencer;

  uvm_analysis_port #(rv32_transaction)  item_collected_port;

	`uvm_component_utils(sl_core_i_agent)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

 	function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver    = sl_core_i_drv::type_id::create("driver", this);
    sequencer = sl_core_seqr::type_id::create("sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

`endif