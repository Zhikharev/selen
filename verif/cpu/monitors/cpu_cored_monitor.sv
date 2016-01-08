// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_cored_monitor.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_CORED_MONITOR
`define INC_CPU_CORED_MONITOR

class cpu_cored_monitor; 
  
  virtual core_if vif;
  string name_m;

  function new (string name, virtual core_if c_if);
  	this.vif = c_if;
    this.name_m = name;
  endfunction 

  task run_phase();
  	forever begin
  		@(vif.mon);
  		if(vif.rst) begin
  		end
  		else begin
  			if(vif.mon.req_val) begin
          core_transaction item;
          item = new();
          item.addr = vif.mon.req_addr;
          item.size = vif.mon.req_size;
          item.cop  = vif.mon.req_cop;
          item.be   = vif.mon.req_be;
          do begin
            @(vif.mon);
          end
          while(!vif.mon.ack_val);
          if(item.is_wr()) item.data = vif.mon.req_wdata;
          else item.data = vif.mon.ack_rdata;
          $display("[%0t][%0s] CPU %0s", $time(), name_m, item.sprint());
  			end
  			else begin
  				if(vif.mon.ack_val) begin
 					  $error("[%0t][%0s] Unexpected ack", $time(), name_m);
  				end
  			end
  		end
  	end
  endtask
endclass

`endif