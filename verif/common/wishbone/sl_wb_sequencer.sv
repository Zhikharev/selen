// ----------------------------------------------------------------------------
// FILE NAME      : sl_wb_sequencer.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_WB_SEQUENCER
`define INC_SL_WB_SEQUENCER

class wb_sequencer extends uvm_sequencer #(wb_bus_item);

	`uvm_component_utils(wb_sequencer)

  function new (string name = "wb_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif
