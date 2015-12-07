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

class cpu_wbi_monitor; 
  
  virtual wishbone_if vif;
	rv32_transaction rv32_item;

  function new (virtual wishbone_if wbi_if);
  	this.vif = wbi_if;
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
  			if(vif.mon.cyc && vif.mon.stb && !vif.mon.stall) begin
  				assert(vif.mon.we == 1'b0)
  				else $error("Expect only reads for WBI (we==0)");
  				$display("[%0t][WBI MON] CPU request addr=%0h", $time, vif.mon.addr);
  			end
  		end
  	end
  endtask

  task monitor_ack();
    forever begin
  		@(vif.mon);
  		if(!vif.rst) begin
  			if(vif.mon.ack) begin
  				rv32_item = new();
  				rv32_item.decode(vif.mon.data_in);
  				$display("[%0t][WBI MON] CPU ack %0s", $time, rv32_item.sprint());
  			end
  		end
  	end
  endtask

endclass

`endif