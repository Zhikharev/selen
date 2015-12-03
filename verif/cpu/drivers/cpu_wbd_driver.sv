// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_wbd_driver.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_WBD_DRIVER
`define INC_CPU_WBD_DRIVER

class cpu_wbd_driver; 
  
  virtual wishbone_if vif;

  function new (virtual wishbone_if wbd_if);
  	this.vif = wbd_if;
  endfunction 

  task run_phase();
    forever begin
      @(vif.drv);
      if(vif.rst) begin
        reset_interface();
      end
      else begin
        if(vif.stb) begin
          int delay;
          bit [31:0] data;

          std::randomize(delay with {delay >= 0; delay < 10});
          std::randomize(data);

          repeat(delay) begin 
            clear_interface();
            @(vif.drv);
          end
          vif.data_in <= data;
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