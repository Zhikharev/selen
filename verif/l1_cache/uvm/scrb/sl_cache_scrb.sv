// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_cache_scrb.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : Кэш инстркций и кэш данных должны работать по разным адресам
// ----------------------------------------------------------------------------
`ifndef INC_SL_CACHE_SCRB
`define INC_SL_CACHE_SCRB

`uvm_analysis_imp_decl(_req)
`uvm_analysis_imp_decl(_rsp)
`uvm_analysis_imp_decl(_mau)

class sl_cache_scrb extends uvm_scoreboard;

  `uvm_component_utils(sl_cache_scrb)

  uvm_analysis_imp_req #(sl_core_bus_item, sl_cache_scrb) item_collected_req;
  uvm_analysis_imp_rsp #(sl_core_bus_item, sl_cache_scrb) item_collected_rsp;
  uvm_analysis_imp_mau #(wb_bus_item,      sl_cache_scrb) item_collected_mau;

  semaphore sem;

  uvm_queue #(sl_core_bus_item) req_q;
  sl_core_bus_item req_nc_pl[mem_addr_t];
  sl_core_bus_item req_pl[mem_addr_t];

  sl_cache_mem cache_mem;
  sl_mem mem;

  function new(string name = "sl_cache_scrb", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_req = new("item_collected_req", this);
    item_collected_rsp = new("item_collected_rsp", this);
    item_collected_mau = new("item_collected_mau", this);
    sem = new(1);
    if(!uvm_config_db#(sl_cache_mem)::get(this, "*", "cache_mem", cache_mem)) begin
      `uvm_info("SCRB", "Creating default cache_mem...", UVM_NONE)
      cache_mem = sl_cache_mem::type_id::create("cache_mem");
    end
    if(!uvm_config_db#(sl_mem)::get(this, "*", "mem", mem)) begin
      `uvm_info("SCRB", "Creating default mem...", UVM_NONE)
      mem = sl_mem::type_id::create("mem");
    end
    req_q = new("req_q");
  endfunction

  function cache_addr_t get_mask_addr(cache_addr_t addr);
    // TODO
  endfunction

  // --------------------------------------------
  // FUNCTION: get_alligned_addr
  // --------------------------------------------
  function bit[31:0] get_alligned_addr(bit [31:0] addr);
    return({addr[31:2], 2'b00});
  endfunction

  // --------------------------------------------
  // FUNCTION: write_req
  // --------------------------------------------
  function void write_req(sl_core_bus_item item);
    while(!sem.try_get());
    if(item.is_nc()) begin
      `uvm_info("SCRB", $sformatf("Adding to req_nc_pl with key=%0h", item.addr), UVM_MEDIUM)
      req_nc_pl[item.addr] = item;
    end
    else begin
      cache_addr_t mask_addr;
      mask_addr = get_mask_addr(item.addr);
      `uvm_info("SCRB", $sformatf("Adding to req_pl with key=%0h", mask_addr), UVM_MEDIUM)
      req_pl[mask_addr] = item;
    end
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_rsp
  // --------------------------------------------
  function void write_rsp(sl_core_bus_item item);
    bit [31:0] addr = get_alligned_addr(item.addr);
    while(!sem.try_get());
    if(item.is_wr()) mem.set_mem(addr, item.data);
    else begin
      if(item.data != mem.get_mem(addr))
        `uvm_error("SCRB", $sformatf("Wrong data compared for addr=%0h! Received: %0h Expected: %0h",
        item.addr, item.data, mem.get_mem(addr)))
    end
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_mau
  // --------------------------------------------
  function void write_mau(wb_bus_item item);
    bit [31:0] addr = get_alligned_addr(item.address);
    while(!sem.try_get());
    `uvm_info("SCRB", $sformatf("mem addr=%0h data=%0h",item.address, item.data[0]), UVM_LOW)
    if(item.is_wr()) begin
      if(item.data[0] != mem.get_mem(addr))
        `uvm_error("SCRB", $sformatf("Wrong write data compared for addr=%0h! Received: %0h Expected: %0h",
        item.address, item.data[0], mem.get_mem(addr)))
    end
    else begin
      mem.set_mem(addr, item.data[0]);
    end
    sem.put();
  endfunction

endclass

`endif

