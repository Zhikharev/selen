// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_commit_monitor.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_COMMIT_MONITOR
`define INC_SL_CORE_COMMIT_MONITOR

class sl_core_commit_monitor extends uvm_monitor;

  virtual core_commit_if vif;

  uvm_analysis_port#(sl_core_bus_item) item_collected_port;

  `uvm_component_utils(sl_core_commit_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual core_commit_if)::get(this, "" ,"vif", vif))
    else `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(),".vif"});
    item_collected_port = new("item_collected_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    monitor_transaction();
  endtask

  task monitor_transaction();
    forever begin
      @(vif.mon);
      if (!vif.rst) begin
        if(vif.mon.val) begin
          sl_core_bus_item item;
          item = sl_core_bus_item::type_id::create("item");
          item_collected_port.write(item);
        end
      end
    end
  endtask

endclass

`endif