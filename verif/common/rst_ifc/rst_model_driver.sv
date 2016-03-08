// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME 		  : rst_model_driver.sv
// PROJECT 			  : Z01
// AUTHOR 			  : Grigoriy Zhiharev
// AUTHOR'S EMAIL : zhiharev@tecon.ru
// ----------------------------------------------------------------------------
// DESCRIPTION 		: 
// ----------------------------------------------------------------------------

`ifndef INC_RST_MODEL_DRIVER
`define INC_RST_MODEL_DRIVER

class rst_model_driver extends rst_driver;

	`uvm_component_utils(rst_model_driver)
    function new (string name = "rst_model_driver", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction

    // Clear interface
    virtual task clear_interface();
      model::reset();
      vif.rst      <= 1'b1;
      vif.soft_rst <= 1'b0;
    endtask

    // Drive item
    virtual task drive_item (rst_transfer item);
      repeat(item.pre_rst_wait_clk) @(posedge vif.clk); 
      vif.rst <= 1'b0;
      repeat(item.pre_rst_wait_clk) @(posedge vif.clk); 
      `uvm_info(get_name(), $sformatf("Expecting %0d cycles of reset", item.rst_wait_clk), UVM_MEDIUM)
      vif.rst <= 1'b1;
      repeat(item.rst_wait_clk) @(posedge vif.clk); 
      vif.rst <= 1'b0;
      repeat(item.rst_wait_clk) @(posedge vif.clk); 
      model::reset();
    endtask

endclass

`endif