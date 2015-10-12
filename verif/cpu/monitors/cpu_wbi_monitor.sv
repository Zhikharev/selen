// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbi_monitor.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBI_MONITOR
`define INC_CPU_WBI_MONITOR

class cpu_wbi_monitor 
  
  virtual wishbone_if wbi_intf vif;

  function new (virtual wishbone_if wbi_if);
  	this.vif = wbi_if;
  endfunction 

  task run_phase();
  endtask
endclass

`endif