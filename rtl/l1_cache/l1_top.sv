// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : write-through, no-write-allocate
//                  L1 instruction cache, L1 data cacche and Memory Access Unit
//                  with Wishnone interface
// ----------------------------------------------------------------------------
`ifndef INC_L1_TOP
`define INC_L1_TOP

module l1_top
(
	input 													clk,
	input 													rst_n,

	// L1I interface
	input 													l1i_req_val,
	input 	[`CORE_ADDR_WIDTH-1:0] 	l1i_req_addr,
	output                        	l1i_req_ack,
	output	[`CORE_DATA_WIDTH-1:0] 	l1i_ack_data,

	// L1D interface
	input 													l1d_req_val,
	input 	[`CORE_ADDR_WIDTH-1:0] 	l1d_req_addr,
	input 	[`CORE_COP_WIDTH-1:0]   l1d_req_cop,
	input 	[`CORE_DATA_WIDTH-1:0] 	l1d_req_wdata,
	input 	[`CORE_SIZE_WIDTH-1:0]  l1d_req_size,
	input 	[`CORE_BE_WIDTH-1:0]    l1d_req_be,
	output                        	l1d_req_ack,
	output	[`CORE_DATA_WIDTH-1:0] 	l1d_ack_data,

	// Wishbone B4 interface
	input 											 		wb_clk_i,
	input 											 		wb_rst_i,
	input  [`CORE_DATA_WIDTH-1:0] 	wb_dat_i,
	output [`CORE_DATA_WIDTH-1:0] 	wb_dat_o,
	input 											 		wb_ack_i,
	output [`CORE_ADDR_WIDTH-1:0] 	wb_adr_o,
	output                       		wb_cyc_o,
	input                        		wb_stall_i,
	input                        		wb_err_i, 	// not used now
	output                      		wb_lock_o, 	// not used now
	input                        		wb_rty_i, 	// not used now
	output [`CORE_BE_WIDTH-1:0]   	wb_sel_o,
	output                       		wb_stb_o,
	output                       		wb_tga_o, 	// not used now
	output                       		wb_tgc_o, 	// not used now
	output                       		wb_we_o
);

	wire	 												l1i_mau_req_val;
	wire 	[`CORE_ADDR_WIDTH-1:0]	l1i_mau_req_addr;
	wire 													l1i_mau_req_ack;
	wire 	[`L1_LINE_SIZE-1:0] 		l1i_mau_ack_data;

	wire	 												l1d_mau_req_val;
	wire                         	l1d_mau_req_nc;
	wire                       		l1d_mau_req_we;
	wire 	[`CORE_ADDR_WIDTH-1:0]	l1d_mau_req_addr;
	wire  [`CORE_DATA_WIDTH-1:0] 	l1d_mau_req_wdata;
	wire  [`CORE_BE_WIDTH-1:0]    l1d_mau_req_be;
	wire 													l1d_mau_req_ack;
	wire 	[`L1_LINE_SIZE-1:0] 		l1d_mau_ack_data;
	wire                          l1d_mau_ack_nc;
	wire                          l1d_mau_ack_we;

	l1i_top l1i
	(
		.clk 						 (clk),
		.rst_n 					 (rst_n),
		.core_req_val 	 (l1i_req_val),
		.core_req_addr 	 (l1i_req_addr),
		.core_req_ack 	 (l1i_req_ack),
		.core_ack_data 	 (l1i_ack_data),
		.mau_req_val 		 (l1i_mau_req_val),
		.mau_req_addr 	 (l1i_mau_req_addr),
		.mau_req_ack 		 (l1i_mau_req_ack),
		.mau_ack_data 	 (l1i_mau_ack_data)
	);

	l1d_top l1d
	(
		.clk 						(clk),
		.rst_n 					(rst_n),
		.core_req_val 	(l1d_req_val),
		.core_req_addr 	(l1d_req_addr),
		.core_req_cop 	(l1d_req_cop),
		.core_req_wdata (l1d_req_wdata),
		.core_req_size 	(l1d_req_size),
		.core_req_ack 	(l1d_req_ack),
		.core_ack_data 	(l1d_ack_data),
		.mau_req_val 		(l1d_mau_req_val),
		.mau_req_nc 		(l1d_mau_req_nc),
		.mau_req_we 		(l1d_mau_req_we),
		.mau_req_addr 	(l1d_mau_req_addr),
		.mau_req_wdata 	(l1d_mau_req_wdata),
		.mau_req_be 		(l1d_mau_req_be),
		.mau_req_ack 		(l1d_mau_req_ack),
		.mau_ack_data 	(l1d_mau_ack_data),
		.mau_ack_nc    	(l1d_mau_ack_nc),
		.mau_ack_we     (l1d_mau_ack_we)
	);

	l1_mau mau
	(
		// L1I interface
		.l1i_req_val 		 (l1i_mau_req_val),
		.l1i_req_addr 	 (l1i_mau_req_addr),
		.l1i_req_ack 		 (l1i_mau_req_ack),
		.l1i_ack_data 	 (l1i_mau_ack_data),
		// L1D interface
		.l1d_req_val 		 (l1d_mau_req_val),
		.l1d_req_we 		 (l1d_mau_req_we),
		.l1d_req_nc   	 (l1d_mau_req_nc),
		.l1d_req_addr 	 (l1d_mau_req_addr),
		.l1d_req_wdata 	 (l1d_mau_req_wdata),
		.l1d_req_be 		 (l1d_mau_req_be),
		.l1d_req_ack 	 	 (l1d_mau_req_ack),
		.l1d_ack_data 	 (l1d_mau_ack_data),
		.l1d_ack_nc      (l1d_mau_ack_nc),
		.l1d_ack_we   	 (l1d_mau_ack_we),
		// Wishbone B4 interface
		.wb_clk_i 			 (wb_clk_i),
		.wb_rst_i 			 (wb_rst_i),
		.wb_dat_i 			 (wb_dat_i),
		.wb_dat_o 			 (wb_dat_o),
		.wb_ack_i 			 (wb_ack_i),
		.wb_adr_o 			 (wb_adr_o),
		.wb_cyc_o 			 (wb_cyc_o),
		.wb_stall_i 		 (wb_stall_i),
		.wb_err_i 			 (wb_err_i), 	// not used now
		.wb_lock_o 			 (wb_lock_o), 	// not used now
		.wb_rty_i 			 (wb_rty_i), 	// not used now
		.wb_sel_o 			 (wb_sel_o),
		.wb_stb_o 			 (wb_stb_o),
		.wb_tga_o 			 (wb_tga_o), 	// not used now
		.wb_tgc_o 			 (wb_tgc_o), 	// not used now
		.wb_we_o 				 (wb_we_o)
	);

endmodule
`endif