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
`uvm_analysis_imp_decl(_commit)

class sl_core_scrb extends uvm_scoreboard;

  `uvm_component_utils(sl_core_scrb)

  string core_reg_file_path;
  bit do_compare;

  uvm_analysis_imp_instr  #(sl_core_bus_item, sl_core_scrb) item_collected_instr;
  uvm_analysis_imp_data   #(sl_core_bus_item, sl_core_scrb) item_collected_data;
  uvm_analysis_imp_commit #(sl_core_bus_item, sl_core_scrb) item_collected_commit;

  uvm_queue #(rv32_transaction) rv32_instr_q;
  uvm_queue #(core_addr_t) pc_q;

  semaphore sem;

  function new(string name = "sl_core_bus_item", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_instr = new("item_collected_instr", this);
    item_collected_data = new("item_collected_data", this);
    item_collected_commit = new("item_collected_commit", this);

    rv32_instr_q = new("rv32_instr_q");
    pc_q = new("pc_q");

    sem = new(1);

    if(!uvm_config_db#(string)::get(this, "*", "core_reg_file_path", core_reg_file_path))
      `uvm_fatal("SCRB", "Can't get core_reg_file_path string!")
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
    assert(core_model::set_mem(item.addr, item.data))
    else `uvm_error("MODEL", "set_mem failed!")
    pc_q.push_back(item.addr);
    do_compare = 1;
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_data
  // --------------------------------------------
  function void write_data(sl_core_bus_item item);
    while(!sem.try_get());
    `uvm_info("SCRB", $sformatf("Memmory acess cop=%0s addr=%0h data=%0h",
    item.cop.name(), item.addr, item.data), UVM_LOW)
    if(!item.is_wr()) begin
      `uvm_info("SCRB", $sformatf("set_mem addr=%0h data=%0h",item.addr, item.data), UVM_LOW)
      assert(core_model::set_mem(item.addr, item.data))
      else `uvm_error("MODEL", "set_mem failed!")
    end
    else begin
      `uvm_info("SCRB", "How should we implemet writes?", UVM_LOW)
    end
    sem.put();
  endfunction

  // --------------------------------------------
  // FUNCTION: write_commit
  // --------------------------------------------
  function void write_commit(sl_core_bus_item item);
    fork
      #0;
      while(!sem.try_get());
      if(do_compare) begin
        if(!compare_state()) `uvm_error("SCRB", "State compare failed!")
        `uvm_info("SCRB", "model step", UVM_LOW)
        assert(core_model::step())
        else `uvm_error("MODEL", "step failed!")
      end
      sem.put();
    join_none
  endfunction

  function bit compare_state();
    bit [31:0] core_reg;
    bit [31:0] model_reg;
    core_addr_t model_pc;
    core_addr_t core_pc;
    bit retval = 1;
    if(pc_q.size() == 0) `uvm_fatal("SCRB", "No items at commit stage expected!")
    core_pc = pc_q.pop_front();
    assert(core_model::get_pc(model_pc))
    else `uvm_error("MODEL", "get_pc failed!")
    if(core_pc != model_pc) begin
      retval = 0;
     `uvm_error("SCRB", $sformatf("PC compare failed. Received: %32h Expected: %32h", core_pc, model_pc))
    end
    for(int i = 0; i < 32; i++) begin
      assert(core_model::get_reg(i, model_reg))
      else `uvm_error("MODEL", "get_reg failed!")
      assert(uvm_hdl_read($sformatf("%0s[%0d]", core_reg_file_path, i), core_reg))
      else `uvm_error("SCRB", $sformatf("Can't get core register[%0d] with path = %0s",i, core_reg_file_path))
      if(core_reg != model_reg) begin
        retval = 0;
        `uvm_error("SCRB", $sformatf("REG[%0d] compare failed. Received: %32h Expected: %32h", i, core_reg, model_reg))
      end
      `uvm_info("STATE_TRACE", $sformatf("REG[%0d] %0h",i, model_reg), UVM_LOW)
    end
    return(retval);
  endfunction

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    if(pc_q.size() != 0) `uvm_error("SCRB", $sformatf("pc_q is not empty (%0d)", pc_q.size()))
  endfunction

endclass

`endif

