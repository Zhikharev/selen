// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_base_test.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CORE_BASE_TEST
`define INC_SL_CORE_BASE_TEST

class sl_core_base_test extends uvm_test;

  `uvm_component_utils(sl_core_base_test)

  sl_core_env  tb_env;
  int          num_pkts;
  bit          test_pass;

  sl_core_agent_cfg core_instr_agent_cfg;
  sl_core_agent_cfg core_data_agent_cfg;

  function new(string name = "core_base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Report server
     set_my_server();

    tb_env = sl_core_env::type_id::create("tb_env", this);
    uvm_default_line_printer.knobs.reference = 0;
    uvm_default_line_printer.knobs.footer = 0;

    // Core agent configuration
    core_instr_agent_cfg = sl_core_agent_cfg::type_id::create("core_instr_agent_cfg");
    core_instr_agent_cfg.port = INSTR;
    uvm_config_db #(sl_core_agent_cfg)::set(this, "*core_instr_agent*", "cfg", core_instr_agent_cfg);
    core_data_agent_cfg = sl_core_agent_cfg::type_id::create("core_data_agent_cfg");
    core_data_agent_cfg.port = DATA;
    uvm_config_db #(sl_core_agent_cfg)::set(this, "*core_data_agent*", "cfg", core_data_agent_cfg);

    // Simulation opts
    if($value$plusargs("num_pkts=%d", num_pkts));
    uvm_config_db #(int)::set(null, "*", "num_pkts", num_pkts);

  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(),$psprintf("Printing the test topology :\n%s", this.sprint()), UVM_HIGH)
    uvm_top.set_report_id_action_hier("MON INSTR", UVM_NO_ACTION);
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 5000);
  endtask

  function void extract_phase(uvm_phase phase);
      uvm_report_server srvr = uvm_report_server::get_server();
      test_pass = (srvr.get_severity_count(UVM_ERROR) == 0) && (srvr.get_severity_count(UVM_FATAL) == 0);
  endfunction

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

class draft_test extends sl_core_base_test;

  `uvm_component_utils(draft_test)

  function new(string name = "draft_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    core_instr_agent_cfg.drv_fixed_delay = 1;
    core_instr_agent_cfg.drv_delay_max = 5;
    uvm_config_db#(uvm_object_wrapper)::set(this,
    "*virtual_seqr.main_phase", "default_sequence", core_alu_seq::type_id::get());
  endfunction
endclass

`endif