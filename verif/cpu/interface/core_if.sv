// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : core_if.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CORE_IF
`define INC_CORE_IF

interface core_if (input logic clk, input logic rst);
	logic 				req_val;
	logic [31:0]	req_addr;
	logic [2:0]   req_cop;
	logic [31:0] 	req_wdata;
	logic [2:0]   req_size;
	logic [3:0]   req_be;
	logic         ack_val;
	logic [31:0]  ack_rdata;

	clocking drv @(posedge clk);
		output ack_val;
		output ack_rdata;
		input req_val;
		input req_addr;
		input req_cop;
		input req_wdata;
		input req_size;
		input req_be;
	endclocking

	clocking mon @(negedge clk);
		input req_val;
		input req_addr;
		input req_cop;
		input req_wdata;
		input req_size;
		input req_be;
		input ack_val;
		input ack_rdata;
	endclocking

endinterface

`endif