// ----------------------------------------------------------------------------
// FILE NAME      : wb_item.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_WB_ITEM
`define INC_WB_ITEM

class wb_item extends uvm_sequence_item;

	rand bit [`CORE_ADDR_WIDTH:0] address;
	rand bit [`CORE_DATA_WIDTH:0] data[$];
	rand bit 											strb;
	rand bit 											err;
	rand cop_t 										cop;

	`uvm_object_utils_begin(wb_item)
		`uvm_field_int(address,         			UVM_DEFAULT)
		`uvm_field_int(strb,         					UVM_DEFAULT)
		`uvm_field_int(err,         					UVM_DEFAULT)
		`uvm_field_int_queue(data,         		UVM_DEFAULT)
		`uvm_field_int_enum(cop, cop_t,       UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "wb_item");
		super.new(name);
	endfunction

endclass

`endif
