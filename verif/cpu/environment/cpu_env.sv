// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_env.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_ENV
`define INC_CPU_ENV

class cpu_env extends cpu_base_component; 

  cpu_wbi_agent wbi_agent;
  cpu_wbd_agent wbd_agent; 

  base_seq seq_q[$];

  function new (virtual wishbone_if wbi_intf, virtual wishbone_if wbd_intf, virtual reset_if rst_intf);
    super.new(wbi_intf, wbd_intf, rst_intf);
    wbi_agent = new(wbi_intf, wbd_intf, rst_intf);
    wbd_agent = new(wbi_intf, wbd_intf, rst_intf);
  endfunction 

  function void build_phase();
    $display("[%0t][ENV][BUILD] Phase started", $time);
    wbi_agent.driver.seq_q = this.seq_q;
    wbi_agent.driver.build_phase();
    $display ("[%0t][ENV][BUILD] Phase ended", $time);   
  endfunction

  task run_phase();
    $display("[%0t][ENV][[RUN] Phase started", $time);
    fork
      wbi_agent.run_phase();
      wbd_agent.run_phase();
    join_any
    $display ("[%0t][ENV][RUN] Phase ended", $time);    
  endtask

  function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction

endclass

`endif