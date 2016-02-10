// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : selen_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SELEN_TOP
`define INC_SELEN_TOP

module selen_top
(
	input clk,
	input	rst_n
);

	wire  [`WB_COM_AWIDTH - 1:0]      cpu_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      cpu_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    cpu_wb_sel_o;
	wire                              cpu_wb_cyc_o;
	wire                              cpu_wb_stb_o;
	wire                              cpu_wb_we_o;

	wire	[`WB_COM_DWIDTH - 1:0]      cpu_wb_dat_i;
	wire                              cpu_wb_stall_i;
	wire                              cpu_wb_ack_i;
	wire                              cpu_wb_err_i;

	selen_cpu_cluster cpu_cluster
	(
		.clk 				(clk),
		.rst_n 			(rst_n),
		.wb_clk_i 	(clk),
		.wb_rst_i 	(~rst_n),
		.wb_dat_i 	(cpu_wb_dat_i),
		.wb_dat_o 	(cpu_wb_dat_o),
		.wb_ack_i 	(cpu_wb_ack_i),
		.wb_adr_o 	(cpu_wb_addr_o),
		.wb_cyc_o 	(cpu_wb_cyc_o),
		.wb_stall_i (cpu_wb_stall_i),
		.wb_err_i 	(cpu_wb_err_i),
		.wb_lock_o 	(),
		.wb_rty_i 	(1'b0),
		.wb_sel_o 	(cpu_wb_sel_o),
		.wb_stb_o 	(cpu_wb_stb_o),
		.wb_tga_o 	(),
		.wb_tgc_o 	(),
		.wb_we_o 		(cpu_wb_we_o)
	);

	wb_com_top wb_xbar
	(
		.clk_i 					(clk),
		.rst_i 					(~rst_n),
		// Master 0 wb interface
		.m0_wb_addr_o 	(cpu_wb_addr_o),
		.m0_wb_dat_o 		(cpu_wb_dat_o),
		.m0_wb_sel_o 		(cpu_wb_sel_o),
		.m0_wb_cyc_o 		(cpu_wb_cyc_o),
		.m0_wb_stb_o 		(cpu_wb_stb_o),
		.m0_wb_we_o 		(cpu_wb_we_o),
		.m0_wb_dat_i 		(cpu_wb_dat_i),
		.m0_wb_stall_i 	(cpu_wb_stall_i),
		.m0_wb_ack_i 		(cpu_wb_ack_i),
		.m0_wb_err_i 		(cpu_wb_err_i),
		// Master 1 wb interface
		.m1_wb_addr_o 	(),
		.m1_wb_dat_o 		(),
		.m1_wb_sel_o 		(),
		.m1_wb_cyc_o 		(1'b0),
		.m1_wb_stb_o 		(1'b0),
		.m1_wb_we_o 		(),
		.m1_wb_dat_i 		(),
		.m1_wb_stall_i 	(),
		.m1_wb_ack_i 		(),
		.m1_wb_err_i 		(),
		// Slave 0 wb interface
		.s0_wb_addr_o 	(),
		.s0_wb_dat_o 		(),
		.s0_wb_sel_o 		(),
		.s0_wb_cyc_o 		(),
		.s0_wb_stb_o 		(),
		.s0_wb_we_o 		(),
		.s0_wb_dat_i 		(),
		.s0_wb_stall_i 	(),
		.s0_wb_ack_i 		(),
		// Slave 1 wb interface
		.s1_wb_addr_o 	(),
		.s1_wb_dat_o 		(),
		.s1_wb_sel_o 		(),
		.s1_wb_cyc_o 		(),
		.s1_wb_stb_o 		(),
		.s1_wb_we_o 		(),
		.s1_wb_dat_i 		(),
		.s1_wb_stall_i 	(1'b0),
		.s1_wb_ack_i 		(1'b0)
	);

endmodule

`endif