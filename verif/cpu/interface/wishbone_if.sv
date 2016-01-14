// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : wishbone_if.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_WISHBONE_IF
`define INC_WISHBONE_IF

interface wishbone_if (input logic clk, input logic rst);
	logic 				cyc;
	logic 				stb;
	logic         we;
	logic [3:0] 	be;
	logic [31:0] 	addr;
	logic  				ack;
	logic [31:0] 	data_in;
	logic [31:0] 	data_out;
	logic 				stall;

	clocking drv @(posedge clk);
	endclocking

	clocking mon @(negedge clk);
		input cyc;
		input stb;
		input we;
		input be;
		input addr;
		input ack;
		input data_in;
		input data_out;
		input stall;
	endclocking

endinterface

`endif