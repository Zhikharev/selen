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
  
  virtual wishbone_if vif;

  base_seq seq_q[$];

  function new (virtual wishbone_if wbi_if);
  	this.vif = wbi_if;
  endfunction 

  task run_phase();
    $display("[%0t][WBI DRV][[RUN] Phase started", $time);
    foreach(seq_q[i]) begin
    	base_seq seq;
    	if(!$cast(seq, seq_q[i])) $fatal("Cast failed!");
    	seq.body();
    	foreach(seq.req_q[i]) begin
    		rv32_transaction req;
    		if(!$cast(req, seq.req_q[i])) $fatal("Cast failed");
    		drive_item(req);
    	end
    end
    $display("[%0t][WBI DRV][[RUN] Phase ended", $time);
  endtask

  task drive_item(rv32_transaction item);
    forever begin
      @(vif.drv);
      if(vif.rst) begin
        reset_interface();
      end
      else begin
        // TODO: сделать конвейерную отработку, cyc
        if(vif.stb) begin
          int delay;
          std::randomize(delay with {delay >= 0; delay < 10});
          repeat(delay) begin 
            clear_interface();
            @(vif.drv);
          end
          vif.data_in <= item.encode();
          vif.ack <= 1'b1;
        end
        else begin
          clear_interface();
        end
      end
    end
  endtask

  task reset_interface();
    vif.ack     <= 0;
    vif.data_in <= 0;
    vif.stall   <= 0;
  endtask

  task clear_interface();
    vif.ack <= 0;
  endtask


endclass

`endif