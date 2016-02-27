// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_env.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : maksim.s.kobzar@gmail.com
// ----------------------------------------------------------------------------

`ifndef INC_L1_ENV
`define INC_L1_ENV

class l1_env extends uvm_env;

  `uvm_component_utils(l1_env)

  rst_agent l1_rst_agent;

  sl_cache_scrb       scrb;

  sl_core_master_agent            l1i_agent;
  sl_core_master_agent            l1d_agent;
  wb_slave_agent                  wb_agent;

  function new(string name = "l1_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      l1_rst_agent = rst_agent::type_id::create("rst_agent", this);

      l1i_agent = sl_core_master_agent::type_id::create("l1i_agent", this);
      l1i_agent.is_active = UVM_ACTIVE;
      l1d_agent = sl_core_master_agent::type_id::create("l1d_agent", this);
      l1d_agent.is_active = UVM_PASSIVE;
      wb_agent = wb_slave_agent::type_id::create("wb_agent", this);
      wb_agent.is_active = UVM_ACTIVE;
      scrb = sl_cache_scrb::type_id::create("scrb", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    l1i_agent.monitor.item_request_port.connect(scrb.item_collected_req);
    l1d_agent.monitor.item_request_port.connect(scrb.item_collected_req);
    l1i_agent.monitor.item_collected_port.connect(scrb.item_collected_rsp);
    l1d_agent.monitor.item_collected_port.connect(scrb.item_collected_rsp);
    wb_agent.monitor.item_collected_port.connect(scrb.item_collected_mau);
  endfunction : connect_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = _global_reporter.get_report_server();

    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0) begin
      $display(" +-----------------------------------------------------------------------------+");
      $display(" |                                 TEST PASSED                                 |");
      $display(" +-----------------------------------------------------------------------------+");
    end
    else begin
      $display(" ________________________________________________________________________");
      $display("|                                                                       |");
      $display("|                              TEST FAILED                              |");
      $display("|_______________________________________________________________________|");
    end
   endfunction
endclass
`endif
