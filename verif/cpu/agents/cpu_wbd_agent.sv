// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbd_agent.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBD_AGENT
`define INC_CPU_WBD_AGENT

class cpu_wbd_agent extends cpu_base_component; 

	cpu_wbd_driver 	driver;
	cpu_wbd_monitor monitor;

  function new (virtual wishbone_if wbi_intf, virtual wishbone_if wbd_intf, reset_if rst_intf);
    super(wbi_intf, wbd_intf, rst_intf);
    driver  = new(wbd_intf);
    monitor = new(wbd_intf);
  endfunction 

  task run_phase();
  	fork
  		driver.run_phase();
  		monitor.run_phase();
  	join_any
  endtask

endclass

`endif
