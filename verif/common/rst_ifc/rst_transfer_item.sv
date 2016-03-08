// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME 		: rst_transfer_item.sv
// PROJECT 			: Z01
// AUTHOR 			: Grigoriy Zhiharev
// AUTHOR'S EMAIL 	: zhiharev@tecon.ru
// ----------------------------------------------------------------------------
// DESCRIPTION 		: 
// ----------------------------------------------------------------------------

`ifndef INC_RST_ITEM
`define INC_RST_ITEM

class rst_transfer extends uvm_sequence_item;
    rand int pre_rst_wait_clk;
    rand int rst_wait_clk;
    rand bit soft;
    `uvm_object_utils_begin(rst_transfer)
        `uvm_field_int(pre_rst_wait_clk, UVM_DEFAULT)
        `uvm_field_int(rst_wait_clk,     UVM_DEFAULT)
        `uvm_field_int(soft,             UVM_DEFAULT)
    `uvm_object_utils_end

    constraint c_rst {
        pre_rst_wait_clk > 100; pre_rst_wait_clk < 300;
        rst_wait_clk     > 100; rst_wait_clk     < 1000;
    }

    function new(string name = "");
        super.new(name);
    endfunction

endclass

`endif
