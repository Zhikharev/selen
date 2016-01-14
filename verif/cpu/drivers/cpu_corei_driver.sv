// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_corei_driver.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : Driver with core interface for instruction port
// ----------------------------------------------------------------------------

`ifndef INC_CPU_COREI_DRIVER
`define INC_CPU_COREI_DRIVER

class cpu_corei_driver #(type REQ_T = rv32_transaction); 
  
  virtual core_if vif;

  base_seq    seq_q[$];
  REQ_T       common_q[$];
  semaphore   sem_m;
  string      name_m;
  int         delay_m;

  function new (string name, virtual core_if c_if);
  	this.vif = c_if;
    this.name_m = name;
    sem_m = new(1);
  endfunction 

  virtual function void build_phase();
    $display("[%0t][%0s][BUILD] Phase started", $time, name_m);
    $display ("[%0t][%0s][BUILD] Phase ended", $time, name_m);   
  endfunction

  task run_phase();
    $display("[%0t][%0s][[RUN] Phase started", $time, name_m);
    foreach(seq_q[i]) begin
      base_seq seq;
      if(!$cast(seq, seq_q[i])) $fatal("Cast failed!");
      seq.body();
      $display("[%0t][%0s] Planning common instruction queue...", $time(), name_m);
      foreach(seq.req_q[i]) begin
        REQ_T req;
        if(!$cast(req, seq.req_q[i])) $fatal("Cast failed");
        common_q.push_back(req);
      end
      drive_items();
    end
    $display("[%0t][%0s][[RUN] Phase ended", $time(), name_m);
  endtask

  task drive_items();
    process_req();
  endtask

  task process_req();
    forever begin
      @(vif.drv);
      while(!sem_m.try_get());
      if(vif.rst) begin
        reset_interface();
      end
      else begin
        if(vif.drv.req_val) begin
          REQ_T item;
          std::randomize(delay_m) with {
            delay_m dist {0 :/ 90, [5:20] :/ 10};
          };
          repeat(delay_m) begin
            clear_interface();
            @(vif.drv);
          end
          assert($cast(item, common_q.pop_front()))
          else $fatal("Cast failed!");
          vif.drv.ack_rdata <= item.encode();
          vif.drv.ack_val  <= 1'b1;
        end
        else begin
          clear_interface();
        end
      end
      if(common_q.size() == 0) begin 
        clear_interface();
        break;
      end
    end
  endtask

  task reset_interface();
    vif.ack_val   <= 0;
    vif.ack_rdata <= 0;
  endtask

  task clear_interface();
    vif.ack_val <= 0;
  endtask


endclass

`endif
