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
  	forever begin
  		@(vif.mon);
  		if(vif.rst) begin
  		end
  		else begin
  			if(vif.mon.stb) begin
  				case(vif.mon.we)
  		  		1'b0: $display("[%0t][WBD MON] CPU READ  request addr=%0h", $time, vif.mon.addr);
  		  		1'b1: $display("[%0t][WBD MON] CPU WRITE request addr=%0h data=%0h", $time, vif.mon.addr, vif.mon.data_out);
  				endcase
  				do begin
  					@(vif.mon);
  				end
  				while(!vif.mon.ack);
  				$display("[%0t][WBD MON] CPU ack data=%0h", $time, vif.mon.data_in);
  			end
  			else begin
  				if(vif.mon.ack) begin
 					$error("[%0t][WBD MON] Unexpected ack", $time);
  				end
  			end
  		end
  	end
  endtask
endclass

`endif