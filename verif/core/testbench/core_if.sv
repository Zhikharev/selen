// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : core_if.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CORE_IF
`define INC_CORE_IF

interface core_if(input wire clk, input wire rst);
	logic 			 req_val;
	logic [2:0]  req_cop;
	logic [2:0]  req_size;
	logic [31:0] req_addr;
	logic [31:0] req_wdata;
	logic        req_ack;
	logic [31:0] req_ack_data;

	clocking drv @(posedge clk);
		input req_val;
		input req_cop;
		input req_size;
		input req_addr;
		input req_wdata;
		output req_ack;
		output req_ack_data;
	endclocking

	clocking mon @(negedge clk);
		input req_val;
		input req_cop;
		input req_size;
		input req_addr;
		input req_wdata;
		input req_ack;
		input req_ack_data;
	endclocking	
endinterface

`endif
