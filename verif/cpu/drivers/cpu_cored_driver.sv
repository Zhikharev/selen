// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_cored_driver.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : Driver with core interface for data port
// ----------------------------------------------------------------------------

`ifndef INC_CPU_CORED_DRIVER
`define INC_CPU_CORED_DRIVER

class cpu_cored_driver; 
  
  virtual core_if vif;

  string      name_m;

  function new (string name, virtual core_if c_if);
  	this.vif = c_if;
    this.name_m = name;
  endfunction 

  task run_phase();
    forever begin
      @(vif.drv);
      if(vif.rst) begin
        reset_interface();
      end
      else begin
        if(vif.req_val) begin
          int delay;
          bit [31:0] data;

          std::randomize(delay) with {delay >= 0 && delay < 10;};
          std::randomize(data);

          repeat(delay) begin 
            clear_interface();
            @(vif.drv);
          end
          vif.ack_rdata <= data;
          vif.ack_val  <= 1'b1;
        end
        else begin
          clear_interface();
        end
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
