`ifndef INC_SL_WB_INTERFACE
`define INC_SL_WB_INTERFACE

interface wb_if (input logic clk, input logic rst);

	logic [`WB_DATA_WIDTH-1:0] 	dat_i;
	logic [`WB_DATA_WIDTH-1:0] 	dat_o;
	logic 											ack;
	logic [`WB_ADDR_WIDTH-1:0] 	adr;
	logic                       cyc;
	logic                       stall;
	logic                       err;
	logic                      	lock;
	logic                       rty;
	logic [`WB_BE_WIDTH-1:0]   	sel;
	logic                       stb;
	logic                       tga;
	logic                       tgc;
	logic                       we;


	clocking drv_m @(posedge clk);
		input  			dat_i;
		output  		dat_o;
		input 			ack;
		output  		adr;
		output      cyc;
		input       stall;
		input       err;
		output      lock;
		input       rty;
		output   		sel;
		output      stb;
		output      tga;
		output      tgc;
		output      we;
  endclocking

  clocking drv_s @(posedge clk);
		output  		dat_i;
		input  			dat_o;
		output 			ack;
		input  			adr;
		input      	cyc;
		output      stall;
		output      err;
		input      	lock;
		output      rty;
		input   		sel;
		input      	stb;
		input      	tga;
		input      	tgc;
		input      	we;
  endclocking

  clocking mon @(negedge clk);
		input  		dat_i;
		input  		dat_o;
		input 		ack;
		input  		adr;
		input     cyc;
		input     stall;
		input     err;
		input     lock;
		input     rty;
		input   	sel;
		input     stb;
		input     tga;
		input     tgc;
		input     we;
  endclocking

endinterface

`endif