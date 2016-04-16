// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_datatypes.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_L1_DATATYPES
`define INC_SL_L1_DATATYPES

typedef struct packed {
	bit [31:13] tag;
	bit [12:5]  idx;
	bit [4:0]   offset;
} l1_addr_t;

typedef enum int {
	LOW 		= 0,
	MEDIUM 	= 1,
	HIGH  	= 2
} l1_num_t;

`endif