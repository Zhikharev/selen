`ifndef INC_WB_INTERFACE
`define INC_WB_INTERFACE

interface wb_if (input logic clk, input logic rst);

	logic 												clk_i;
	logic 											 	rst_i;
	logic [`CORE_DATA_WIDTH-1:0] 	dat_i;
	logic [`CORE_DATA_WIDTH-1:0] 	dat_o;
	logic 											 	ack_i;
	logic [`CORE_ADDR_WIDTH-1:0] 	adr_o;
	logic                       	cyc_o;
	logic                        	stall_i;
	logic                        	err_i;
	logic                      		lock_o;
	logic                        	rty_i;
	logic [`CORE_BE_WIDTH-1:0]   	sel_o;
	logic                       	stb_o;
	logic                       	tga_o;
	logic                       	tgc_o;
	logic                       	we_o;


	clocking drv_m @(posedge clk);
		input 			clk_i;
		input 			rst_i;
		input  			dat_i;
		output  		dat_o;
		input 			ack_i;
		output  		adr_o;
		output      cyc_o;
		input       stall_i;
		input       err_i;
		output      lock_o;
		input       rty_i;
		output   		sel_o;
		output      stb_o;
		output      tga_o;
		output      tgc_o;
		output      we_o;
  endclocking

  clocking drv_s @(posedge clk);
		input 			clk_i;
		input 			rst_i;
		output  		dat_i;
		input  			dat_o;
		output 			ack_i;
		input  			adr_o;
		input      	cyc_o;
		output      stall_i;
		output      err_i;
		input      	lock_o;
		output      rty_i;
		input   		sel_o;
		input      	stb_o;
		input      	tga_o;
		input      	tgc_o;
		input      	we_o;
  endclocking

  clocking mon @(posedge clk);
		input 		clk_i;
		input 		rst_i;
		input  		dat_i;
		input  		dat_o;
		input 		ack_i;
		input  		adr_o;
		input     cyc_o;
		input     stall_i;
		input     err_i;
		input     lock_o;
		input     rty_i;
		input   	sel_o;
		input     stb_o;
		input     tga_o;
		input     tgc_o;
		input     we_o;
  endclocking

endinterface

`endif