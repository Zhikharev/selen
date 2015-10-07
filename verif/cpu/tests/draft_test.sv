// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : draft_test.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_DRAFT_TEST
`define INC_DRAFT_TEST

class draft_test; 
	virtual wishbone_if wbi_intf;
	virtual wishbone_if wbd_intf;
	virtual reset_if    rst_intf;

  cpu_env env;

  function new (virtual wishbone_if wbi_if, virtual wishbone_if wbd_if, reset_if rst_if);
    this.wbi_intf = wbi_if;
    this.wbd_intf = wbd_if;
    this.rst_intf = rst_if;
  endfunction 

  virutal function void build_phase();
    $display("[%0t][BUILD] Phase started", $time);
    $display ("[%0t][BUILD] Phase ended", $time);   
  endfunction

  task run_phase();
    $display("[%0t][RUN] Phase started", $time);
    $display ("[%0t][RUN] Phase ended", $time);    
  endtask

  virutal function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction

endclass

`endif