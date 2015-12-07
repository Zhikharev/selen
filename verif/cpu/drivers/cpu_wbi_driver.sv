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
  rv32_transaction common_q[$];

  int active_req;
  int max_active_req = 5;

  semaphore sem;

  function new (virtual wishbone_if wbi_if);
  	this.vif = wbi_if;
    sem = new(1);
  endfunction 

  function void build_phase();
    $display("[%0t][WBI DRV][BUILD] Phase started", $time);
    $display("[%0t] Planning common instruction queue...", $time());
    foreach(seq_q[i]) begin
      base_seq seq;
      if(!$cast(seq, seq_q[i])) $fatal("Cast failed!");
      seq.body();
      foreach(seq.req_q[i]) begin
        rv32_transaction req;
        if(!$cast(req, seq.req_q[i])) $fatal("Cast failed");
        common_q.push_back(req);
      end
    end
    $display ("[%0t][WBI DRV][BUILD] Phase ended", $time);   
  endfunction

  task run_phase();
    $display("[%0t][WBI DRV][[RUN] Phase started", $time);
    fork
      process_req();
      process_ack();
    join_any
    wait(active_req == 0);
    disable fork;
    $display("[%0t][WBI DRV][[RUN] Phase ended", $time);
  endtask

  task process_req();
    forever begin
      @(vif.drv);
      while(!sem.try_get());
      if(vif.rst) begin
        reset_interface();
        active_req = 0;
      end
      else begin
        if(vif.cyc && vif.stb) begin
          if(active_req >= max_active_req) begin
            vif.stall <= 1'b1;
          end
          else begin
            active_req++;
            vif.stall <= 1'b0;
          end
        end
      end
      sem.put();
      if(common_q.size() == 0) break;
    end
  endtask


  task process_ack();
    int delay;
    forever begin
      @(vif.drv);
      if(!vif.rst) begin
        while(!sem.try_get());
        if(active_req > 0) begin
          sem.put();
          std::randomize(delay) with {delay >= 0; delay < 10;};
          repeat(delay) begin 
            clear_interface();
            @(vif.drv);
          end
          forever begin
            rv32_transaction item;
            while(!sem.try_get());
            item = common_q.pop_front();
            vif.data_in <= item.encode();
            vif.ack <= 1'b1;
            active_req--;
            if(active_req == 0) begin
              sem.put();
              break;
            end
            else begin
              sem.put();
              @(vif.drv);
            end
          end
        end
        else begin
          vif.ack <= 1'b0;
          sem.put();
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
