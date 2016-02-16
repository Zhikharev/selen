// ----------------------------------------------------------------------------
// FILE NAME      : wb_monitor.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_WB_MONITOR
`define INC_WB_MONITOR

class wb_monitor extends uvm_monitor;

  typedef virtual wb_if vif_t;
  vif_t vif;

  `uvm_component_utils(wb_monitor)

  uvm_analysis_port #(wb_item) item_collected_port;

  function new (string name = "wb_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    if(!uvm_config_db#(smt_router_port_cfg)::get(this, "", "port_cfg", port_cfg))
      `uvm_fatal("NOCFG", {"Configuration must be set for ", get_full_name(), ".port_cfg"})
  endfunction

  task run_phase(uvm_phase phase);
    manage_packet();
  endtask

  task manage_packet();
    forever begin
      @(vif.mon);
      if(vif.mon.MEM_req) begin
        wb_item item;
        item = wb_item::type_id::create("item");
        collect_packet(item);
        assert(item.randomize(null))
        else `uvm_error(get_full_name(), "Packet doesn't fit constraints!")
        item_collected_port.write(item);
      end
    end
  endtask

  // --------------------------------------------
  // TASK: collect_packet
  // --------------------------------------------
  task collect_packet(ref wb_item item);
    item.cop      = vif.mon.we_o;
    item.address  = vif.mon.adr_o;
    item.strb     = vif.mon.stb_o;
    item.err      = vif.mon.err_i;
    if(item.cop == WRITE)
      item.data     = vif.mon.dat_o;
    else
      item.data     = vif.mon.dat_i;
  endtask

endclass

`endif
