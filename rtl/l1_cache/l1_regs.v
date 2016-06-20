// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_regs.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : Register block
//
// 1.0 		20.06.16  	Начальная версия
// ----------------------------------------------------------------------------

`ifndef INC_L1_REGS
`define INC_L1_REGS

module l1_regs
(
	input 															clk,
	input 															rst_n,

	// Register access interface
	// Wishbone B4
	input 											 		wb_clk_i,
	input 											 		wb_rst_i,
	input  [`CORE_DATA_WIDTH-1:0] 	wb_dat_i,
	output [`CORE_DATA_WIDTH-1:0] 	wb_dat_o,
	input 											 		wb_ack_i,
	output [`CORE_ADDR_WIDTH-1:0] 	wb_adr_o,
	output                       		wb_cyc_o,
	input                        		wb_stall_i,
	input                        		wb_err_i,
	output                      		wb_lock_o, 	// not used now
	input                        		wb_rty_i, 	// not used now
	output [`CORE_BE_WIDTH-1:0]   	wb_sel_o,
	output                       		wb_stb_o,
	output                       		wb_tga_o, 	// not used now
	output                       		wb_tgc_o, 	// not used now
	output                       		wb_we_o,

	// Control signals
	input li_req_val,
	input li_hit_val,
	input ld_req_val,
	input ld_req_val,
	input ld_req_nv_val

);

	reg [15:0] li_req_cnt;
	reg [15:0] li_hit_cnt;
	reg [15:0] ld_req_cnt;
	reg [15:0] ld_hit_cnt;


endmodule
`endif