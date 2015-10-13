// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbd_monitor.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBD_MONITOR
`define INC_CPU_WBD_MONITOR

class cpu_wbd_monitor; 
  
  virtual wishbone_if vif;

  function new (virtual wishbone_if wbd_if);
  	this.vif = wbd_if;
  endfunction 

  task run_phase();
  endtask
endclass

`endif