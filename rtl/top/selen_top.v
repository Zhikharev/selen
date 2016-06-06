// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : selen_top.v
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
	input 	clk,
	input		rst_n,

	output 	gpio_pin0_o,
	output 	gpio_pin0_en,
	input 	gpio_pin0_i,

	output 	gpio_pin1_o,
	output 	gpio_pin1_en,
	input 	gpio_pin1_i,

  output  spi_ss_o,
  output  spi_sclk_o,
  output  spi_mosi_o,
  input   spi_miso_i
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

	wire  [`WB_COM_AWIDTH - 1:0]      com_mem_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      com_mem_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    com_mem_wb_sel_o;
	wire                              com_mem_wb_cyc_o;
	wire                              com_mem_wb_stb_o;
	wire                              com_mem_wb_we_o;
	wire	[`WB_COM_DWIDTH - 1:0]      com_mem_wb_dat_i;
	wire                              com_mem_wb_stall_i;
	wire                              com_mem_wb_ack_i;
	wire                              com_mem_wb_err_i;

	wire  [`WB_COM_AWIDTH - 1:0]      com_io_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      com_io_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    com_io_wb_sel_o;
	wire                              com_io_wb_cyc_o;
	wire                              com_io_wb_stb_o;
	wire                              com_io_wb_we_o;
	wire	[`WB_COM_DWIDTH - 1:0]      com_io_wb_dat_i;
	wire                              com_io_wb_stall_i;
	wire                              com_io_wb_ack_i;
	wire                              com_io_wb_err_i;

	wire  [`WB_COM_AWIDTH - 1:0]      io_rom_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      io_rom_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    io_rom_wb_sel_o;
	wire                              io_rom_wb_cyc_o;
	wire                              io_rom_wb_stb_o;
	wire                              io_rom_wb_we_o;
	wire	[`WB_COM_DWIDTH - 1:0]      io_rom_wb_dat_i;
	wire                              io_rom_wb_stall_i;
	wire                              io_rom_wb_ack_i;
	wire                              io_rom_wb_err_i;

	wire  [`WB_COM_AWIDTH - 1:0]      io_perif_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      io_perif_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    io_perif_wb_sel_o;
	wire                              io_perif_wb_cyc_o;
	wire                              io_perif_wb_stb_o;
	wire                              io_perif_wb_we_o;
	wire	[`WB_COM_DWIDTH - 1:0]      io_perif_wb_dat_i;
	wire                              io_perif_wb_rty_i;
	wire                              io_perif_wb_ack_i;
	wire                              io_perif_wb_err_i;
	wire                              io_perif_wb_stall_i;

	wire [30:0] 											gpio_pins_o;
	wire [30:0] 											gpio_pins_en;
	wire [30:0] 											gpio_pins_i;

	assign gpio_pin0_o  	= gpio_pins_o[0];
	assign gpio_pin0_en 	= gpio_pins_en[0];
	assign gpio_pins_i[0] = gpio_pin0_i;

	assign gpio_pin1_o  	= gpio_pins_o[1];
	assign gpio_pin1_en 	= gpio_pins_en[1];
	assign gpio_pins_i[1] = gpio_pin1_i;

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

	defparam wb_cpu_xbar.S0_ADDR_LO = 32'h0000_0000;
	defparam wb_cpu_xbar.S0_ADDR_HI = 32'h0000_2fff;
	defparam wb_cpu_xbar.S1_ADDR_LO = 32'h0010_0000;
	defparam wb_cpu_xbar.S1_ADDR_HI = 32'h001f_ffff;

	wb_com_top wb_cpu_xbar
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
		.s0_wb_addr_o 	(com_io_wb_addr_o),
		.s0_wb_dat_o 		(com_io_wb_dat_o),
		.s0_wb_sel_o 		(com_io_wb_sel_o),
		.s0_wb_cyc_o 		(com_io_wb_cyc_o),
		.s0_wb_stb_o 		(com_io_wb_stb_o),
		.s0_wb_we_o 		(com_io_wb_we_o),
		.s0_wb_dat_i 		(com_io_wb_dat_i),
		.s0_wb_stall_i 	(com_io_wb_stall_i),
		.s0_wb_err_i 		(com_io_wb_err_i),
		.s0_wb_ack_i 		(com_io_wb_ack_i),
		// Slave 1 wb interface
		.s1_wb_addr_o 	(com_mem_wb_addr_o),
		.s1_wb_dat_o 		(com_mem_wb_dat_o),
		.s1_wb_sel_o 		(com_mem_wb_sel_o),
		.s1_wb_cyc_o 		(com_mem_wb_cyc_o),
		.s1_wb_stb_o 		(com_mem_wb_stb_o),
		.s1_wb_we_o 		(com_mem_wb_we_o),
		.s1_wb_dat_i 		(com_mem_wb_dat_i),
		.s1_wb_stall_i 	(com_mem_wb_stall_i),
		.s1_wb_err_i 		(com_mem_wb_err_i),
		.s1_wb_ack_i 		(com_mem_wb_ack_i)
	);

	defparam wb_ram_256kB.DW = 32;
	defparam wb_ram_256kB.AW = 10; // TODO 1024 byte, change name

	wb_ram wb_ram_256kB
	(
  	.wb_clk_i 	(clk),
  	.wb_rst_i 	(~rst_n),
  	.wb_dat_i 	(com_mem_wb_dat_o),
  	.wb_dat_o 	(com_mem_wb_dat_i),
  	.wb_adr_i 	(com_mem_wb_addr_o),
  	.wb_sel_i 	(com_mem_wb_sel_o),
  	.wb_we_i 		(com_mem_wb_we_o),
  	.wb_cyc_i 	(com_mem_wb_cyc_o),
  	.wb_stb_i 	(com_mem_wb_stb_o),
  	.wb_ack_o 	(com_mem_wb_ack_i),
  	.wb_err_o 	(com_mem_wb_err_i)
	);

	assign com_mem_wb_stall_i = 1'b0;

	defparam wb_perif_xbar.S0_ADDR_LO = 32'h0000_0000;
	defparam wb_perif_xbar.S0_ADDR_HI = 32'h0000_0fff;
	defparam wb_perif_xbar.S1_ADDR_LO = 32'h0000_1000;
	defparam wb_perif_xbar.S1_ADDR_HI = 32'h0000_2fff;

	wb_com_top wb_perif_xbar
	(
		.clk_i 					(clk),
		.rst_i 					(~rst_n),
		// Master 0 wb interface
		.m0_wb_addr_o 	(com_io_wb_addr_o),
		.m0_wb_dat_o 		(com_io_wb_dat_o),
		.m0_wb_sel_o 		(com_io_wb_sel_o),
		.m0_wb_cyc_o 		(com_io_wb_cyc_o),
		.m0_wb_stb_o 		(com_io_wb_stb_o),
		.m0_wb_we_o 		(com_io_wb_we_o),
		.m0_wb_dat_i 		(com_io_wb_dat_i),
		.m0_wb_stall_i 	(com_io_wb_stall_i),
		.m0_wb_ack_i 		(com_io_wb_ack_i),
		.m0_wb_err_i 		(com_io_wb_err_i),
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
		.s0_wb_addr_o 	(io_rom_wb_addr_o),
		.s0_wb_dat_o 		(io_rom_wb_dat_o),
		.s0_wb_sel_o 		(io_rom_wb_sel_o),
		.s0_wb_cyc_o 		(io_rom_wb_cyc_o),
		.s0_wb_stb_o 		(io_rom_wb_stb_o),
		.s0_wb_we_o 		(io_rom_wb_we_o),
		.s0_wb_dat_i 		(io_rom_wb_dat_i),
		.s0_wb_stall_i 	(io_rom_wb_stall_i),
		.s0_wb_err_i 		(io_rom_wb_err_i),
		.s0_wb_ack_i 		(io_rom_wb_ack_i),
		// Slave 1 wb interface
		.s1_wb_addr_o 	(io_perif_wb_addr_o),
		.s1_wb_dat_o 		(io_perif_wb_dat_o),
		.s1_wb_sel_o 		(io_perif_wb_sel_o),
		.s1_wb_cyc_o 		(io_perif_wb_cyc_o),
		.s1_wb_stb_o 		(io_perif_wb_stb_o),
		.s1_wb_we_o 		(io_perif_wb_we_o),
		.s1_wb_dat_i 		(io_perif_wb_dat_i),
		.s1_wb_stall_i 	(io_perif_wb_stall_i),
		.s1_wb_err_i 		(io_perif_wb_err_i),
		.s1_wb_ack_i 		(io_perif_wb_ack_i)
	);

	defparam wb_rom_5kB.DW = 32;
	defparam wb_rom_5kB.AW = 11;

	assign io_rom_wb_stall_i = 1'b0;

	wb_rom wb_rom_5kB
	(
  	.wb_clk_i 	(clk),
  	.wb_rst_i 	(~rst_n),
  	.wb_dat_i 	(io_rom_wb_dat_o),
  	.wb_dat_o 	(io_rom_wb_dat_i),
  	.wb_adr_i 	(io_rom_wb_addr_o),
  	.wb_sel_i 	(io_rom_wb_sel_o),
  	.wb_we_i 		(io_rom_wb_we_o),
  	.wb_cyc_i 	(io_rom_wb_cyc_o),
  	.wb_stb_i 	(io_rom_wb_stb_o),
  	.wb_ack_o 	(io_rom_wb_ack_i),
  	.wb_err_o 	(io_rom_wb_err_i)
	);

	assign io_perif_wb_stall_i = 1'b0;

	selen_perif_cluster perif_cluster
	(
		.clk 					(clk),
		.rst_n 				(rst_n),
  	.wb_adr_i 		(io_perif_wb_addr_o),
  	.wb_dat_i 		(io_perif_wb_dat_o),
  	.wb_dat_o 		(io_perif_wb_dat_i),
 		.wb_we_i 			(io_perif_wb_we_o),
 		.wb_sel_i 		(io_perif_wb_sel_o),
  	.wb_stb_i 		(io_perif_wb_stb_o),
  	.wb_ack_o 		(io_perif_wb_ack_i),
  	.wb_err_o 		(io_perif_wb_err_i),
  	.wb_rty_o 		(io_perif_wb_rty_i),
  	.wb_cyc_i 		(io_perif_wb_cyc_o),
		.gpio_pins_o	(gpio_pins_o),
		.gpio_pins_en (gpio_pins_en),
		.gpio_pins_i 	(gpio_pins_i),
  	.spi_ss_o    	(spi_ss_o),
  	.spi_sclk_o 	(spi_sclk_o),
  	.spi_mosi_o 	(spi_mosi_o),
  	.spi_miso_i 	(spi_miso_i)
);




endmodule

`endif