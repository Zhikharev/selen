// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : core_model_dpi.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

package core_model;

	typedef struct
	{
  	int unsigned pc_start;
  	int unsigned mem_size;
  	int unsigned verbose;     // 1 yes, 0 no - allow error messages/debug output
  	int unsigned mem_resize;  // 1 yes, 0 no - allow resize memory when try to write at invalid address
  	int unsigned endiannes; 	// 1 big endian, 0 little - memory read/write endiannes
	} s_model_params;

	import "DPI-C" context function int init(input s_model_params params);;
	import "DPI-C" context function int set_mem(input int unsigned addr, input int unsigned data);
	import "DPI-C" context function int get_mem(input int unsigned addr, output int unsigned data);
	import "DPI-C" context function int set_reg(input int reg_id, input int unsigned data);
	import "DPI-C" context function int get_reg(input int reg_id, output int unsigned data);
	import "DPI-C" context function int set_pc(input int unsigned data);
	import "DPI-C" context function int get_pc(output int unsigned data);
	import "DPI-C" context function int step();

endpackage : core_model