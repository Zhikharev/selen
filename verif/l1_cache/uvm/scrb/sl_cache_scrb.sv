// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_cache_scrb.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CACHE_SCRB
`define INC_SL_CACHE_SCRB

`uvm_analysis_imp_decl(_instr)
`uvm_analysis_imp_decl(_data)
`uvm_analysis_imp_decl(_mau)

class sl_cache_scrb extends uvm_scoreboard;

  `uvm_component_utils(sl_cache_scrb)

  uvm_analysis_imp_instr #(sl_core_bus_item, sl_cache_scrb) item_collected_instr;
  uvm_analysis_imp_data  #(sl_core_bus_item, sl_cache_scrb) item_collected_data;
  uvm_analysis_imp_mau   #(sl_wb_bus_item,   sl_cache_scrb) item_collected_mau;

  semaphore sem;

  sl_cache_mem cache_mem;

  function new(string name = "sl_cache_scrb", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_instr = new("item_collected_instr", this);
    item_collected_data = new("item_collected_data", this);
    item_collected_mau = new("item_collected_mau", this);
    sem = new(1);
    if(!uvm_config_db#()::get(this, "*", "cache_mem", cache_mem)) begin
      `uvm_info("SCRB", "Creating default cache_mem...", UVM_NONE)
      cache_mem = sl_cache_mem::type_id::create("cache_mem");
    end
  endfunction

  // --------------------------------------------
  // FUNCTION: write_instr
  // --------------------------------------------
  function void write_instr(sl_core_bus_item item);
    while(!sem.try_get());
      if(item.is_nc()) begin
      end
      else begin
        if(item.is_wr()) cache_mem.set_line_data(item.addr, item.data);
      end
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_data
  // --------------------------------------------
  function void write_data(sl_core_bus_item item);
    while(!sem.try_get());
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_mau
  // --------------------------------------------
  function void write_mau(sl_wb_bus_item item);
    while(!sem.try_get());
      cache_mem.set_line_state(item.addr, SHARED);
    sem.put();
  endfunction

endclass

`endif

