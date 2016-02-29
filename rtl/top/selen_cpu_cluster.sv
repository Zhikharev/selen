// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : selen_cpu_cluster.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SELEN_CPU_CLUSTER
`define INC_SELEN_CPU_CLUSTER

module selen_cpu_cluster
(
	input 													clk,
	input 													rst_n,

	// Wishbone B4 interface
	input 											 		wb_clk_i,
	input 											 		wb_rst_i,
	input  [`CORE_DATA_WIDTH-1:0] 	wb_dat_i,
	output [`CORE_DATA_WIDTH-1:0] 	wb_dat_o,
	input 											 		wb_ack_i,
	output [`CORE_ADDR_WIDTH-1:0] 	wb_adr_o,
	output                       		wb_cyc_o,
	input                        		wb_stall_i,
	input                        		wb_err_i,
	output                      		wb_lock_o,
	input                        		wb_rty_i,
	output [`CORE_BE_WIDTH-1:0]   	wb_sel_o,
	output                       		wb_stb_o,
	output                       		wb_tga_o,
	output                       		wb_tgc_o,
	output                       		wb_we_o
);

	// L1I interface
	wire 													l1i_req_val;
	wire 	[`CORE_ADDR_WIDTH-1:0] 	l1i_req_addr;
	wire                        	l1i_req_ack;
	wire	[`CORE_DATA_WIDTH-1:0] 	l1i_ack_data;

	// L1D interface
	wire 													l1d_req_val;
	wire 	[`CORE_ADDR_WIDTH-1:0] 	l1d_req_addr;
	wire 	[`CORE_COP_WIDTH-1:0]   l1d_req_cop;
	wire 	[`CORE_DATA_WIDTH-1:0] 	l1d_req_wdata;
	wire 	[`CORE_SIZE_WIDTH-1:0]  l1d_req_size;
	wire 	[`CORE_BE_WIDTH-1:0]    l1d_req_be;
	wire                        	l1d_req_ack;
	wire	[`CORE_DATA_WIDTH-1:0] 	l1d_ack_data;

	core_top core
	(
  	.clk 					(clk),
  	.rst_n 				(rst_n),
  	.i_req_val 		(l1i_req_val),
  	.i_req_addr 	(l1i_req_addr),
  	.i_req_ack 		(l1i_req_ack),
  	.i_ack_rdata 	(l1i_ack_data),
  	.d_req_val 		(l1d_req_val),
  	.d_req_addr 	(l1d_req_addr),
  	.d_req_cop 		(l1d_req_cop),
  	.d_req_wdata 	(l1d_req_wdata),
  	.d_req_size 	(l1d_req_size),
  	.d_req_ack 		(l1d_req_ack),
  	.d_ack_rdata 	(l1d_ack_data)
);

	l1_top l1_cache
(
	.clk 						(clk),
	.rst_n 					(rst_n),
	.l1i_req_val 		(l1i_req_val),
	.l1i_req_addr 	(l1i_req_addr),
	.l1i_req_ack 		(l1i_req_ack),
	.l1i_ack_data 	(l1i_ack_data),
	.l1d_req_val 		(l1d_req_val),
	.l1d_req_addr 	(l1d_req_addr),
	.l1d_req_cop 		(l1d_req_cop),
	.l1d_req_wdata 	(l1d_req_wdata),
	.l1d_req_size 	(l1d_req_size),
	.l1d_req_be 		(),
	.l1d_req_ack 		(l1d_req_ack),
	.l1d_ack_data 	(l1d_ack_data),
	.wb_clk_i 			(wb_clk_i),
	.wb_rst_i 			(wb_rst_i),
	.wb_dat_i 			(wb_rst_i),
	.wb_dat_o 			(wb_dat_o),
	.wb_ack_i 			(wb_ack_i),
	.wb_adr_o 			(wb_adr_o),
	.wb_cyc_o 			(wb_cyc_o),
	.wb_stall_i 		(wb_stall_i),
	.wb_err_i 			(wb_err_i), 	// not used now
	.wb_lock_o 			(wb_lock_o), 	// not used now
	.wb_rty_i 			(wb_rty_i), 	// not used now
	.wb_sel_o 			(wb_sel_o),
	.wb_stb_o 			(wb_stb_o),
	.wb_tga_o 			(wb_tga_o), 	// not used now
	.wb_tgc_o 			(wb_tgc_o), 	// not used now
	.wb_we_o 				(wb_we_o)
);


endmodule

`endif