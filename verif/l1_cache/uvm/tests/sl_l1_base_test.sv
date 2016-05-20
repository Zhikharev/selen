// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_base_test.sv
// PROJECT        : Selen
// AUTHOR         :
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
  sl_global_cfg     global_cfg;

  function new(string name = "l1_base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    set_my_server();
    if($value$plusargs("num_pkts=%d", num_pkts));
    uvm_config_db #(int)::set(null, "*", "num_pkts", num_pkts);
    uvm_default_line_printer.knobs.reference = 0;
    uvm_default_line_printer.knobs.footer = 0;
    global_cfg = sl_global_cfg::type_id::create("global_cfg");
    assert(global_cfg.randomize());
    custom_cfg();
    `uvm_info("CFG", global_cfg.sprint(), UVM_LOW)
    uvm_config_db #(sl_core_agent_cfg)::set(this, "*l1i*", "cfg", global_cfg.i_cfg);
    uvm_config_db #(sl_core_agent_cfg)::set(this, "*l1d*", "cfg", global_cfg.d_cfg);
    uvm_config_db #(wb_agent_cfg)::set(this, "*wb*",  "cfg", global_cfg.wb_cfg);
    uvm_config_db #(sl_l1_cfg)::set(this, "*l1i*",  "cfg", global_cfg.li_cfg);
    uvm_config_db #(sl_l1_cfg)::set(this, "*l1d*",  "cfg", global_cfg.ld_cfg);
    tb_env = l1_env::type_id::create("tb_env", this);
    uvm_config_db#(uvm_object_wrapper)::set(this, "*.rst_agent.sequencer.reset_phase","default_sequence", rst_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*wb_agent.sequencer.run_phase", "default_sequence", wb_slave_response_sequence::type_id::get());


    // Factory ovverides
    set_type_override_by_type(sl_core_bus_item::get_type(), sl_l1_core_bus_item::get_type());

  endfunction

  virtual function void custom_cfg();
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
    // Запрос в кэш-память данных появится только после того как будет получена инструкция из кэш-памяти
    // инструкций. По сбросу кэш не сразу готов работать. В $I есть автоматическая блокировка для такого
    // случая, в $D блокировки нет
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1d_agent.sequencer.post_main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
  endfunction

endclass

`endif
