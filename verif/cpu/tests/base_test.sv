// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : base_test.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_BASE_TEST
`define INC_BASE_TEST

class base_test extends cpu_base_component; 

  cpu_env env;

  function new (virtual wishbone_if wbi_intf, virtual wishbone_if wbd_intf, reset_if rst_intf);
    super(wbi_intf, wbd_intf, rst_intf);
    env = new(wbi_intf, wbd_intf, rst_intf);  
  endfunction 

  virutal function void build_phase();
  endfunction

  virtual task run_phase();
    $display("[%0t][BASE TEST][RUN] Phase started", $time);
    env.run_phase();
    $display ("[%0t][BASE TEST][RUN] Phase ended", $time);  
  endtask

  virutal function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction

endclass

`endif