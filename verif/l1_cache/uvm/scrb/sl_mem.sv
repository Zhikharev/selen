// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_mem.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_MEM
`define INC_SL_MEM

typedef bit [31:0] mem_data_t;
typedef bit [31:0] mem_addr_t;

class sl_mem extends uvm_object;

	semaphore sem;

   protected mem_data_t mem[mem_addr_t];

	`uvm_object_utils(sl_mem)

	function new(string name = "sl_mem");
		super.new(name);
		sem = new(1);
	endfunction

	// ------------------------------------------------------
	// FUNCTION: set_mem
	// ------------------------------------------------------
 	function void set_mem(mem_addr_t addr, mem_data_t data);
 		mem[addr] = data;
 	endfunction

	// ------------------------------------------------------
	// FUNCTION: get_mem
	// ------------------------------------------------------
 	function mem_data_t get_mem(mem_addr_t addr);
 		return(mem[addr]);
 	endfunction

endclass
`endif