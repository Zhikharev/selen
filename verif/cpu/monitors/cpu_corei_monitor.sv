// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_corei_monitor.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_COREI_MONITOR
`define INC_CPU_COREI_MONITOR

class cpu_corei_monitor #(type REQ_T = rv32_transaction); 
  
  virtual core_if vif;
	REQ_T item_m;
  string name_m;

  function new (string name, virtual core_if c_if);
  	this.vif = c_if;
    this.name_m = name;
  endfunction 

  task run_phase();
  	fork
  		monitor_req();
  		monitor_ack();
  	join
  endtask

  task monitor_req();
   	forever begin
  		@(vif.mon);
  		if(!vif.rst) begin
  			if(vif.mon.req_val) begin
  				$display("[%0t][%0s] CPU request addr=%0h", $time(), name_m, vif.mon.req_addr);
  			end
  		end
  	end
  endtask

  task monitor_ack();
    forever begin
  		@(vif.mon);
  		if(!vif.rst) begin
  			if(vif.mon.ack_val) begin
  				item_m = new();
  				item_m.decode(vif.mon.ack_rdata);
  				$display("[%0t][%0s] CPU ack %0s", $time(), name_m, item_m.sprint());
  			end
  		end
  	end
  endtask

endclass

`endif