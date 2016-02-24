// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_master_agent.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL : maksim.s.kobzar@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CORE_MASTER_AGENT
`define INC_SL_CORE_MASTER_AGENT

class sl_core_master_agent extends uvm_agent;

	sl_core_master_driver  driver;
	sl_core_sequencer     sequencer;
  sl_core_monitor       monitor;

  sl_core_agent_cfg     agent_cfg;

  uvm_analysis_port #(sl_core_bus_item)  item_collected_port;

	`uvm_component_utils(sl_core_master_agent)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

 	function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(this.get_is_active() == UVM_ACTIVE) begin
      driver    = sl_core_master_driver::type_id::create("driver", this);
      sequencer = sl_core_sequencer::type_id::create("sequencer", this);
    end
    monitor= sl_core_monitor::type_id::create("monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(this.get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    monitor.item_collected_port.connect(item_collected_port);
  endfunction
endclass

`endif