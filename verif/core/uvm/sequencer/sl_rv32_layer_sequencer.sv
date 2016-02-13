// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_rv32_layer_sequencer.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_RV32_LAYER_SEQUENCER
`define INC_SL_RV32_LAYER_SEQUENCER

typedef class sl_rv32_core_translate_seq;

class sl_rv32_layer_sequencer extends uvm_sequencer#(rv32_transaction);

	`uvm_component_utils(sl_rv32_layer_sequencer)

	sl_core_sequencer core_sequencer;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

  virtual task run_phase(uvm_phase phase);
  	sl_rv32_core_translate_seq rv32_core_seq;
  	rv32_core_seq = sl_rv32_core_translate_seq::type_id::create("rv32_core_seq");
  	rv32_core_seq.up_sequencer = this;
    fork
      rv32_core_seq.start(core_sequencer);
    join_none
  endtask
endclass

`endif
