// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_rv32_core_translate_seq.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_RV32_CORE_TRANSLATE_SEQ
`define INC_SL_RV32_CORE_TRANSLATE_SEQ

class sl_rv32_core_translate_seq extends uvm_sequence #(sl_core_bus_item);

  `uvm_object_utils(sl_rv32_core_translate_seq);

  function new(string name = "sl_rv32_core_translate_seq");
    super.new(name);
  endfunction

  uvm_sequencer #(rv32_transaction) up_sequencer;

  virtual task body();
    rv32_transaction rv32_item;
    sl_core_bus_item core_bus_item;
    forever begin
      up_sequencer.get_next_item(rv32_item);
      `uvm_create(core_bus_item)
      core_bus_item.data = rv32_item.encode();
      `uvm_send(core_bus_item)
      get_response(core_bus_item);
      up_sequencer.item_done();
      up_sequencer.put_response(rv32_item);
    end
  endtask
endclass

`endif