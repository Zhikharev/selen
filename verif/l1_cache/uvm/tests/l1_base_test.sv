// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_base_test.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_BASE_TEST
`define INC_L1_BASE_TEST

class l1_base_test extends uvm_test;

  `uvm_component_utils(l1_base_test)

  //l1_reg_block  reg_model;
  //global_events_t   global_events;
  //l1_cfg            cfg;
  l1_env            tb_env;

  int               num_pkts = 10;

  function new(string name = "l1_base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Report server
    set_my_server();

    if($value$plusargs("num_pkts=%d", num_pkts));
    uvm_config_db #(int)::set(null, "*", "num_pkts", num_pkts);

    uvm_default_line_printer.knobs.reference = 0;
    uvm_default_line_printer.knobs.footer = 0;

    //global_events = global_events_t::type_id::create("global_events");
    //uvm_config_db #(global_events_t)::set(null, "*", "global_events", global_events);

    // Router configuration
   //cfg = l1_cfg::type_id::create("cfg");
    //uvm_config_db #(l1_cfg)::set(null, "*", "cfg", cfg);

    //`uvm_info(get_full_name(), {"\n", cfg.sprint()}, UVM_LOW)

    // Register layer
    //uvm_reg::include_coverage("*", UVM_CVR_ADDR_MAP + UVM_CVR_FIELD_VALS);
    //reg_model = router_reg_block::type_id::create("reg_model");
    //reg_model.build();
    //reg_model.ctb_map.set_check_on_read(0);
    //reg_model.reset();
    //reg_model.set_coverage(UVM_CVR_ADDR_MAP + UVM_CVR_FIELD_VALS);
    //reg_model.randomize();

    //uvm_config_db#(router_reg_block)::set(null, "*", "reg_model", reg_model);
    //uvm_config_db#(uvm_reg_block)::set(null, "*", "reg_model", reg_model);

    tb_env = l1_env::type_id::create("tb_env", this);

    uvm_config_db#(uvm_object_wrapper)::set(this, "*.rst_agent.sequencer.reset_phase","default_sequence", rst_base_seq::type_id::get());

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(),$psprintf("Printing the test topology :\n%s", this.sprint()), UVM_HIGH)
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
  endfunction : start_of_simulation_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 5000);
  endtask

  function void set_my_server();
      /*advanced_report_server my_server;
      int hwidth, fwidth;
      my_server = new();
      if($test$plusargs("DEFAULT_SERVER"))
          `uvm_info(get_full_name(), "Using default report server", UVM_NONE)
      else begin
          if($value$plusargs("fname_width=%d", fwidth)) my_server.file_name_width = fwidth;
          if($value$plusargs("hier_width=%d", hwidth))  my_server.hier_width = hwidth;
          uvm_report_server::set_server(my_server);
      end*/
      $timeformat(-9, 1, "ns", 4);
  endfunction

endclass

`endif
