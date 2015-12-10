// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : test_lib.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_TEST_LIB
`define INC_TEST_LIB

class direct_test extends base_test; 

  cpu_direct_seq direct_seq;

  function new (virtual wishbone_if wbi_intf, virtual wishbone_if wbd_intf, virtual reset_if rst_intf);
    super.new(wbi_intf, wbd_intf, rst_intf);
  endfunction 

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    direct_seq = new();
    env.seq_q.push_back(direct_seq);
    env.build_phase();
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
  endfunction

  task run_phase();
    $display("[%0t][TEST][RUN] Phase started", $time);
    super.run_phase();
    $display ("[%0t][TEST][RUN] Phase ended", $time);    
  endtask

  function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction

endclass

`endif