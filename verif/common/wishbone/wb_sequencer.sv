// ----------------------------------------------------------------------------
// FILE NAME      : wb_sequencer.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_WB_SEQUENCER
`define INC_WB_SEQUENCER

class wb_sequencer extends uvm_sequencer #(sl_wb_bus_item);

	`uvm_component_utils(wb_sequencer)

	//uvm_analysis_imp #(sl_wb_bus_item, wb_sequencer) rsp_port;

  function new (string name = "wb_sequencer", uvm_component parent);
    super.new(name, parent);
    //rsp_port = new("rsp_port", this);
  endfunction

  //function void write(sl_wb_bus_item item);

  //endfunction

endclass

`endif
