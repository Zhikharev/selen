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

endmodule

`endif