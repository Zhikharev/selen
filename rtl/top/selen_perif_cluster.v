// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : selen_зукша_cluster.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_SELEN_PERIF_CLUSTER
`define INC_SELEN_PERIF_CLUSTER

module selen_perif_cluster
(
	input 													clk,
	input 													rst_n,

	// Wishbone B4 interface
  input  [`CORE_ADDR_WIDTH-1:0]   wb_adr_i,     // ADR_I() address input
  input  [`CORE_DATA_WIDTH-1:0]   wb_dat_i,     // DAT_I() data in
  output [`CORE_DATA_WIDTH-1:0]   wb_dat_o,     // DAT_O() data out
  input                     			wb_we_i,      // WE_I write enable input
  input  [`CORE_BE_WIDTH-1-1:0] 	wb_sel_i,     // SEL_I() select input
  input                     			wb_stb_i,     // STB_I strobe input
  output                    			wb_ack_o,     // ACK_O acknowledge output
  output                    			wb_err_o,     // ERR_O error output
  output                    			wb_rty_o,     // RTY_O retry output
  input                     			wb_cyc_i,     // CYC_I cycle input

  // IO
	output [30:0] 									gpio_pins_o,
	output [30:0] 									gpio_pins_en,
	input [30:0] 										gpio_pins_i
);

	wire  [`WB_COM_AWIDTH - 1:0]      io_gpio_wb_addr_o;
	wire  [`WB_COM_DWIDTH - 1:0]      io_gpio_wb_dat_o;
	wire  [`WB_COM_DWIDTH/8 - 1:0]    io_gpio_wb_sel_o;
	wire                              io_gpio_wb_cyc_o;
	wire                              io_gpio_wb_stb_o;
	wire                              io_gpio_wb_we_o;
	wire	[`WB_COM_DWIDTH - 1:0]      io_gpio_wb_dat_i;
	wire                              io_gpio_wb_rty_i;
	wire                              io_gpio_wb_ack_i;
	wire                              io_gpio_wb_err_i;

	wb_mux_p3 wb_mux
	(
  	.clk 				(clk),
  	.rst 				(~rst_n),

    /*
     * Wishbone master input
     */
    .wbm_adr_i 	(wb_adr_i),
    .wbm_dat_i 	(wb_dat_i),
    .wbm_dat_o 	(wb_dat_o),
    .wbm_we_i 	(wb_we_i),
    .wbm_sel_i 	(wb_sel_i),
    .wbm_stb_i 	(wb_stb_i),
    .wbm_ack_o 	(wb_ack_o),
    .wbm_err_o 	(wb_err_o),
    .wbm_rty_o 	(wb_rty_o),
    .wbm_cyc_i 	(wb_cyc_i),

    /*
     * Wishbone slave 0 output
     */
    .wbs0_adr_o (),
    .wbs0_dat_i (),
    .wbs0_dat_o (),
    .wbs0_we_o  (),
   	.wbs0_sel_o (),
    .wbs0_stb_o (),
    .wbs0_ack_i (1'b0),
    .wbs0_err_i (1'b0),
    .wbs0_rty_i (1'b0),
    .wbs0_cyc_o (),

    /*
     * Wishbone slave 0 address configuration
     */
    .wbs0_addr 		(32'h0000_1000),
    .wbs0_addr_msk(32'h0000_1000),

    /*
     * Wishbone slave 1 output
     */
    .wbs1_adr_o 	(io_gpio_wb_addr_o),
    .wbs1_dat_i 	(io_gpio_wb_dat_i),
    .wbs1_dat_o 	(io_gpio_wb_dat_o),
    .wbs1_we_o 		(io_gpio_wb_we_o),
    .wbs1_sel_o 	(io_gpio_wb_sel_o),
    .wbs1_stb_o 	(io_gpio_wb_stb_o),
    .wbs1_ack_i 	(io_gpio_wb_ack_i),
    .wbs1_err_i 	(io_gpio_wb_err_i),
    .wbs1_rty_i 	(io_gpio_rty_i),
    .wbs1_cyc_o 	(io_gpio_wb_cyc_o),

    /*
     * Wishbone slave 1 address configuration
     */
    .wbs1_addr 		(32'h0000_2000),
    .wbs1_addr_msk(32'h0000_2000),

    /*
     * Wishbone slave 2 output
     */
    .wbs2_adr_o (),
    .wbs2_dat_i (),
    .wbs2_dat_o (),
    .wbs2_we_o  (),
    .wbs2_sel_o (),
    .wbs2_stb_o (),
    .wbs2_ack_i (1'b0),
    .wbs2_err_i (1'b0),
    .wbs2_rty_i (1'b0),
    .wbs2_cyc_o (),

    /*
     * Wishbone slave 2 address configuration
     */
    .wbs2_addr 		(32'h0000_3000),
    .wbs2_addr_msk(32'h0000_3000)
);

	assign io_gpio_wb_rty_i = 1'b0;

	gpio_top gpio
	(
		.wb_clk_i 		(clk),
		.wb_rst_i 		(~rst_n),
		.wb_cyc_i 		(io_gpio_wb_cyc_o),
		.wb_adr_i 		(io_gpio_wb_addr_o),
		.wb_dat_i 		(io_gpio_wb_dat_o),
		.wb_sel_i 		(io_gpio_wb_sel_o),
		.wb_we_i 			(io_gpio_wb_we_o),
		.wb_stb_i 		(io_gpio_wb_stb_o),
		.wb_dat_o 		(io_gpio_wb_dat_i),
		.wb_ack_o 		(io_gpio_wb_ack_i),
		.wb_err_o 		(io_gpio_wb_err_i),
		.wb_inta_o 		(),
		.ext_pad_i 		(gpio_pins_i),
		.ext_pad_o 		(gpio_pins_o),
		.ext_padoe_o 	(gpio_pins_en)
	);

endmodule

`endif