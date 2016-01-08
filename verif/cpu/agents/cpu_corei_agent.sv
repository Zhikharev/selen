// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_corei_agent.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_COREI_AGENT
`define INC_CPU_COREI_AGENT

class cpu_corei_agent extends cpu_base_component #(virtual core_if); 

	cpu_corei_driver 	driver;
	cpu_corei_monitor monitor;

  function new (virtual core_if i_intf, virtual core_if d_intf, virtual reset_if rst_intf);
    super.new(i_intf, d_intf, rst_intf);
    driver  = new("CI DRV", i_intf);
    monitor = new("CI MON", i_intf);
  endfunction 

  task run_phase();
  	fork
  		driver.run_phase();
  		monitor.run_phase();
  	join_any
  endtask

endclass

`endif
