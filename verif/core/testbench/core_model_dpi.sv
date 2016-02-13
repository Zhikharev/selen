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
	} s_model_params;

	import "DPI-C" context function int init(input s_model_params params);;
	import "DPI-C" context function int mem_set(input int unsigned addr, input int unsigned data);
	import "DPI-C" context function int mem_get(input int unsigned addr, output int unsigned data);
	import "DPI-C" context function int reg_get(input int reg_id, output int unsigned data);
	import "DPI-C" context function int step();

endpackage : core_model