// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_cache_typedefs.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SL_CACHE_TYPEDEFS
`define INC_SL_CACHE_TYPEDEFS

	typedef enum {INV, SHARED, MODIFIED} cache_line_state_t;
	typedef bit [31:0] cache_addr_t;
	typedef bit [31:0] cache_data_t;

`endif