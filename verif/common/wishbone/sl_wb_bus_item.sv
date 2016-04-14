// ----------------------------------------------------------------------------
// FILE NAME      : sl_wb_bus_item.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_WB_BUS_ITEM
`define INC_SL_WB_BUS_ITEM

typedef enum bit {
	READ 	= 1'b0,
	WRITE = 1'b1
} cop_t;

class wb_bus_item extends uvm_sequence_item;

	rand bit [`WB_ADDR_WIDTH-1:0] address;
	rand bit [`WB_DATA_WIDTH-1:0] data[$];
	rand bit [`WB_BE_WIDTH-1:0] 	sel;
	rand bit 											err;
	rand cop_t 										cop;
	rand bit 											stall;
	rand int                      stall_clk_num;
	rand bit 											rty;

	`uvm_object_utils_begin(wb_bus_item)
		`uvm_field_int(address,         	UVM_DEFAULT)
		`uvm_field_int(sel,         			UVM_DEFAULT)
		`uvm_field_int(err,         			UVM_DEFAULT)
		`uvm_field_int(rty,         			UVM_DEFAULT)
		`uvm_field_int(stall,         		UVM_DEFAULT)
		`uvm_field_int(stall_clk_num,     UVM_DEFAULT)
		`uvm_field_queue_int(data,        UVM_DEFAULT)
		`uvm_field_enum(cop_t, cop,       UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "wb_bus_item");
		super.new(name);
	endfunction

	constraint c_stall_no_err {stall -> !err;};
	constraint c_stall_clk_num {stall_clk_num >=  1; stall_clk_num < 10;};
	constraint c_data_size {data.size() == 1;};

	function bit is_wr();
		return(cop == WRITE);
	endfunction

	function void disable_drv_constraints();
		this.c_stall_clk_num.constraint_mode(0);
	endfunction

endclass

`endif
