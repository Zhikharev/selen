// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : core_commit_if.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhilharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_CORE_COMMIT_IF
`define INC_CORE_COMMIT_IF

interface core_commit_if(input wire clk, input wire rst);

	logic val;

	clocking drv @(posedge clk);
	endclocking

	clocking mon @(negedge clk);
		input val;
	endclocking
endinterface

`endif
