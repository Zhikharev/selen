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

  l1_env            tb_env;
  bit               test_pass;
  int               num_pkts = 10;
  l1_cfg            cfg;

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

    cfg = l1_cfg::type_id::create("cfg");
    assert(cfg.randomize());
    uvm_config_db #(sl_core_agent_cfg)::set(null, "*l1i*", "cfg", cfg.i_cfg);
    uvm_config_db #(sl_core_agent_cfg)::set(null, "*l1d*", "cfg", cfg.d_cfg);
    uvm_config_db #(wb_agent_cfg)::set(null, "*wb*",  "cfg", cfg.wb_cfg);


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

  function void extract_phase(uvm_phase phase);
      uvm_report_server srvr = uvm_report_server::get_server();
      test_pass = (srvr.get_severity_count(UVM_ERROR) == 0) && (srvr.get_severity_count(UVM_FATAL) == 0);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 5000);
  endtask

  function void report_phase(uvm_phase phase);
    if(test_pass) begin
      $display("                                      :X-");
      $display("                                    :X###");
      $display("                                  ;@####@");
      $display("                                ;x######X");
      $display("       TEST PASSED            -@#########$");
      $display("                            .$###########@");
      $display("                            =M############-");
      $display("                           +##############$");
      $display("                         .H############$=.");
      $display("         ./:            .N##########M:.");
      $display("      -+@NNN;          -##########M;");
      $display("    -*M######         :#########M/");
      $display("  -$M###########     :#########/");
      $display("   ,:x###########:  =########$.");
      $display("        ;H#########+#######N=");
      $display("            ,+##############+");
      $display("               /M#########@-");
      $display("                 ;M######*");
      $display("                   +###:");
    end
    else begin
      $display("            _\\|/_");
      $display("            (o o)");
      $display("    +----oOO-{_}-OOo------------+");
      $display("    |                           |");
      $display("    |                           |");
      $display("    |        TEST FAILED        |");
      $display("    |                           |");
      $display("    |                           |");
      $display("    +---------------------------+");
    end
  endfunction


  function void set_my_server();
      smart_report_server my_server;
      int hwidth, fwidth;
      my_server = new();
      if($test$plusargs("DEFAULT_SERVER"))
          `uvm_info(get_full_name(), "Using default report server", UVM_NONE)
      else begin
          if($value$plusargs("fname_width=%d", fwidth)) my_server.file_name_width = fwidth;
          if($value$plusargs("hier_width=%d", hwidth))  my_server.hier_width = hwidth;
          uvm_report_server::set_server(my_server);
      end
      $timeformat(-9, 1, "ns", 4);
  endfunction

endclass

class draft_test extends l1_base_test;

  `uvm_component_utils(draft_test)

  function new(string name = "draft_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.main_phase", "default_sequence", draft_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1d_agent.sequencer.main_phase", "default_sequence", draft_sequence::type_id::get());
  endfunction

endclass

`endif
