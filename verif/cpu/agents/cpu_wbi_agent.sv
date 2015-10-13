// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbi_agent.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBI_AGENT
`define INC_CPU_WBI_AGENT

class cpu_wbi_agent extends cpu_base_component; 

	cpu_wbi_driver 	driver;
	cpu_wbi_monitor monitor;

  function new (virtual wishbone_if wbi_intf, virtual wishbone_if wbd_intf, virtual reset_if rst_intf);
    super.new(wbi_intf, wbd_intf, rst_intf);
    driver  = new(wbi_intf);
    monitor = new(wbi_intf);
  endfunction 

  task run_phase();
  	fork
  		driver.run_phase();
  		monitor.run_phase();
  	join_any
  endtask

endclass

`endif
