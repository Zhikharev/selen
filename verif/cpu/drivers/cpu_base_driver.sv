// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_base_driver.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_BASE_DRIVER
`define INC_CPU_BASE_DRIVER

class cpu_base_driver #(type REQ_T); 
  
  base_seq seq_q[$];
  REQ_T common_q[$];

  int active_req;
  int max_active_req = 5;

  semaphore sem;

  function new ();
  endfunction 

  virtual function void build_phase();
  endfunction

  task run_phase();
    $display("[%0t][WBI DRV][[RUN] Phase started", $time);
    foreach(seq_q[i]) begin
      base_seq seq;
      if(!$cast(seq, seq_q[i])) $fatal("Cast failed!");
      seq.body();
      $display("[%0t] Planning common instruction queue...", $time());
      foreach(seq.req_q[i]) begin
        rv32_transaction req;
        if(!$cast(req, seq.req_q[i])) $fatal("Cast failed");
        common_q.push_back(req);
      end
      drive_items();
    end
    $display("[%0t][WBI DRV][[RUN] Phase ended", $time);
  endtask

  task drive_items();
    fork
      process_req();
      process_ack();
    join
    disable fork;
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
        if(active_req >= max_active_req) begin
          vif.stall <= 1'b1;
        end
        else begin
          vif.stall <= 1'b0;
        end
        if(vif.cyc && vif.stb) begin
          active_req++;
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
          std::randomize(delay) with {delay >= 0; delay < 20;};
          repeat(delay) begin 
            clear_interface();
            @(vif.drv);
          end
          forever begin
            rv32_transaction item;
            while(!sem.try_get());
            if(common_q.size() == 0) begin
              active_req = 0;
              sem.put();
              return;
            end
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
