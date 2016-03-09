// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_cache_mem.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CACHE_MEM
`define INC_SL_CACHE_MEM

class sl_cache_mem extends uvm_object;

	int cache_data_width = 128;
	cache_addr_t  cache_addr;
	semaphore sem;

   protected sl_cache_line #(128) lines[cache_addr];

	`uvm_object_utils(sl_cache_mem)

	function new(string name = "sl_cache_mem");
		super.new(name);
		sem = new(1);
	endfunction

	// ------------------------------------------------------
	// FUNCTION: set_line_data
	// ------------------------------------------------------
 	function void set_line_data(cache_addr_t addr, cache_data_t data);
 	endfunction

	// ------------------------------------------------------
	// FUNCTION: get_line_data
	// ------------------------------------------------------
 	function cache_data_t get_line_data(cache_addr_t addr);
 	endfunction

	// ------------------------------------------------------
	// FUNCTION: set_line_state
	// ------------------------------------------------------
 	function void set_line_state(cache_addr_t addr, cache_line_state_t state);
 	endfunction

	// ------------------------------------------------------
	// FUNCTION: get_line_state
	// ------------------------------------------------------
 	function cache_line_state_t get_line_state(cache_addr_t addr);
 	endfunction

endclass
`endif