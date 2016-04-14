// ----------------------------------------------------------------------------
// FILE NAME      : sl_wb_monitor.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_WB_MONITOR
`define INC_SL_WB_MONITOR

class wb_monitor extends uvm_monitor;

  typedef virtual wb_if vif_t;
  protected vif_t vif;
  protected wb_bus_item wb_bus_req_q[$];
  bit do_print = 1;

  `uvm_component_utils(wb_monitor)

  uvm_analysis_port #(wb_bus_item) item_collected_port;

  function new (string name = "wb_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  task run_phase(uvm_phase phase);
    manage_packet();
  endtask

  task manage_packet();
    forever begin
      @(vif.mon);
      fork
        begin: REQ
          if(vif.mon.cyc && vif.mon.stb && !vif.mon.stall) begin
            wb_bus_item item;
            item = wb_bus_item::type_id::create("item");
            item.cop = vif.mon.we;
            item.address  = vif.mon.adr;
            item.sel = vif.mon.sel;
            if(item.is_wr()) item.data.push_back(vif.mon.dat_o);
            if(do_print) `uvm_info("WB_MON", $sformatf("%0s (%0h) started", item.cop.name(), item.address), UVM_MEDIUM)
            wb_bus_req_q.push_back(item);
          end
        end
        begin: ACK
          if(vif.mon.ack || vif.mon.err) begin
            wb_bus_item item;
            if(wb_bus_req_q.size() == 0) `uvm_fatal("WB_MON", "Unexpecned ack, wb_bus_req_q is empty!")
            item = wb_bus_req_q.pop_front();
            item.err = vif.mon.err;
            item.rty = vif.mon.rty;
            if(!item.is_wr()) item.data.push_back(vif.mon.dat_i);
            item.disable_drv_constraints();
            assert(item.randomize(null))
            else `uvm_error(get_full_name(), "Packet doesn't fit constraints!")
            if(do_print) `uvm_info("WB_MON", $sformatf("%0s (%0h) finished", item.cop.name(), item.address), UVM_MEDIUM)
            item_collected_port.write(item);
          end
        end
      join
    end
  endtask

endclass

`endif
