// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1_mau.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------
`ifndef INC_L1_MAU
`define INC_L1_MAU

module l1_mau
(

	// L1I interface
	input	 												l1i_req_val,
	input 												l1i_req_addr,
	output 												l1i_req_ack,
	output [`L1_LINE_SIZE-1:0] 		l1i_ack_data,

	// L1D interface
	input	 												l1d_req_val,
	input                       	l1d_req_we
	input 												l1d_req_addr,
	input  [`CORE_DATA_WIDTH-1:0] l1d_req_wdata,
	input  [`CORE_BE_WIDTH-1:0]   l1d_req_be,
	output 												l1d_req_ack,
	output [`L1_LINE_SIZE-1:0] 		l1d_ack_data,

	// Wishbone B4 interface
	input 											 	wb_clk_i,
	input 											 	wb_rst_i,
	input 	[`WB_DATA_WIDTH-1:0] 	wb_dat_i,
	output  [`WB_DATA_WIDTH-1:0] 	wb_dat_o,
	input 											 	wb_ack_i,
	output 	[`WD_ADDR_WIDTH-1:0] 	wb_adr_o,
	output                       	wb_cyc_o,
	input                        	wb_stall_i,
	input                        	wb_err_i, 	// not used now
	output                      	wb_lock_o, 	// not used now
	input                        	wb_rty_i, 	// not used now
	output                      	wb_sel_o,
	output                       	wb_stb_o,
	output                       	wb_tga_o, 	// not used now
	output                       	wb_tgc_o, 	// not used now
	output                       	wb_we_o
);
endmodule

`endif