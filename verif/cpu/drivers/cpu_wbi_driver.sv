// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbi_driver.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBI_DRIVER
`define INC_CPU_WBI_DRIVER

class cpu_wbi_driver; 
  
  virtual wishbone_if wbi_intf vif;

  base_seq seq_q[$];

  function new (virtual wishbone_if wbi_if);
  	this.vif = wbi_if;
  endfunction 

  task run_phase();
    $display("[%0t][WBI DRV][[RUN] Phase started", $time);
    foreach(seq_q[i]) begin
    	base_seq seq;
    	if(!$cast(seq, seq.q[i]) $fatal("Cast failed!");
    	seq.body();
    	foreach(seq.req_q[i]) begin
    		r32v_transaction req;
    		if(!$cast(req, seq.req_q[i])) $fatal("Cast failed");
    		drive_item(req);
    	end
    end
    $display("[%0t][WBI DRV][[RUN] Phase started", $time);
  endtask

  task drive_item(r32v_transaction item);
  	// TODO
  endtask

endclass

`endif