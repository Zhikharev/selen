// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_scrb.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmal.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CORE_SCRB
`define INC_SL_CORE_SCRB

`uvm_analysis_imp_decl(_instr)
`uvm_analysis_imp_decl(_data)
`uvm_analysis_imp_decl(_inner)

class sl_core_scrb extends uvm_scoreboard;

  `uvm_component_utils(sl_core_scrb)

  uvm_analysis_imp_instr #(sl_core_bus_item, sl_core_scrb) item_collected_instr;
  uvm_analysis_imp_data  #(sl_core_bus_item, sl_core_scrb) item_collected_data;
  uvm_analysis_imp_inner #(sl_core_bus_item, sl_core_scrb) item_collected_inner;

  uvm_queue #(rv32_transaction) rv32_instr_q;

  semaphore sem;

  function new(string name = "sl_core_bus_item", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_instr = new("item_collected_instr", this);
    item_collected_data = new("item_collected_data", this);
    item_collected_inner = new("item_collected_inner", this);

    rv32_instr_q = new("rv32_instr_q");

    sem = new(1);
  endfunction

  // --------------------------------------------
  // FUNCTION: write_instr
  // --------------------------------------------
  function void write_instr(sl_core_bus_item item);
    rv32_transaction rv32_item;
    while(!sem.try_get());
    rv32_item = rv32_transaction::type_id::create("rv32_item");
    rv32_item.decode(item.data);
    `uvm_info("SCRB", rv32_item.sprint(), UVM_LOW)
    rv32_instr_q.push_back(rv32_item);
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_data
  // --------------------------------------------
  function void write_data(sl_core_bus_item item);
  endfunction

  // --------------------------------------------
  // FUNCTION: write_inner
  // --------------------------------------------
  function void write_inner(sl_core_bus_item item);
  endfunction

endclass

`endif

