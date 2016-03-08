// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME 		: rst_driver.sv
// PROJECT 			: Z01
// AUTHOR 			: Grigoriy Zhiharev
// AUTHOR'S EMAIL 	: zhiharev@tecon.ru
// ----------------------------------------------------------------------------
// DESCRIPTION 		: 
// ----------------------------------------------------------------------------

`ifndef INC_RST_DRIVER
`define INC_RST_DRIVER

class rst_driver extends uvm_driver #(rst_transfer);
    
    typedef virtual rst_if vif_t;
    vif_t vif;
    rst_transfer tr_item;

	`uvm_component_utils(rst_driver)
    function new (string name = "rst_driver", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        assert(uvm_config_db#(vif_t)::get(this, "" ,"vif", vif))
        else `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(),".vif"});
    endfunction

    task run_phase(uvm_phase phase);
        fork
            clear_interface();
        join_none
        forever begin
            @(posedge vif.clk);
            seq_item_port.try_next_item(tr_item);
            if(tr_item != null) begin
                rst_transfer ret_item;
                $cast(ret_item, tr_item.clone());
                ret_item.set_id_info(tr_item);
                ret_item.accept_tr();
                drive_item(ret_item);
                ret_item.end_tr();
                seq_item_port.item_done();
                seq_item_port.put_response(ret_item);
            end
        end   
    endtask

    // Clear interface
    virtual task clear_interface();
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
    endtask

endclass

`endif