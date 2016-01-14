// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_core_env.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_CORE_ENV
`define INC_CPU_CORE_ENV

class cpu_core_env extends cpu_base_component #(virtual core_if); 

  cpu_corei_agent i_agent;
  cpu_cored_agent d_agent; 

  base_seq seq_q[$];

  function new (virtual core_if i_intf, virtual core_if d_intf, virtual reset_if rst_intf);
    super.new(i_intf, d_intf, rst_intf);
    i_agent = new(i_intf, d_intf, rst_intf);
    d_agent = new(i_intf, d_intf, rst_intf);
  endfunction 

  function void build_phase();
    $display("[%0t][ENV][BUILD] Phase started", $time);
    i_agent.driver.seq_q = this.seq_q;
    i_agent.driver.build_phase();
    $display ("[%0t][ENV][BUILD] Phase ended", $time);   
  endfunction

  task run_phase();
    $display("[%0t][ENV][[RUN] Phase started", $time);
    fork
      i_agent.run_phase();
      d_agent.run_phase();
    join_any
    $display ("[%0t][ENV][RUN] Phase ended", $time);    
  endtask

  function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction
  
endclass

`endif