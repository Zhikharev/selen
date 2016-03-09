// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME        : rst_monitor.sv
// PROJECT          : Z01
// AUTHOR           : Grigoriy Zhiharev
// AUTHOR'S EMAIL   : zhiharev@tecon.ru
// ----------------------------------------------------------------------------
// DESCRIPTION      : 
// ----------------------------------------------------------------------------

`ifndef INC_RST_MONITOR
`define INC_RST_MONITOR

class rst_monitor extends uvm_monitor;

    typedef virtual rst_if vif_t;
    vif_t vif;

    rst_transfer item;

    uvm_analysis_port #(uvm_sequence_item) item_collected_port;

    `uvm_component_utils_begin(rst_monitor)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
    endfunction: build_phase

    task run_phase(uvm_phase phase);
      fork
        begin
          forever begin
            wait(vif.rst == 1'b1);
            `uvm_info("EVENTS", "Reset detected", UVM_MEDIUM)
            //global_events.rst.trigger();
            wait(vif.rst == 1'b0);
            `uvm_info("EVENTS", "Reset ended", UVM_MEDIUM)
            //global_events.rst.reset();
          end
        end
      join
    endtask
    
endclass

`endif