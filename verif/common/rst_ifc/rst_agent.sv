// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME      : rst_agent.sv
// PROJECT        : Z01
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : zhiharev@tecon.ru
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_RST_AGENT
`define INC_RST_AGENT

typedef uvm_sequencer #(rst_transfer) rst_sequencer;

class rst_agent extends uvm_agent;

    rst_driver     driver;
    rst_monitor    monitor;
    rst_sequencer  sequencer;
    
    `uvm_component_utils_begin(rst_agent)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);        
        monitor   = rst_monitor::type_id::create("monitor", this);
        driver    = rst_driver::type_id::create("driver", this);
        sequencer = rst_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction 
endclass

`endif