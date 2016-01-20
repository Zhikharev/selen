// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1_dm_mem.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------
`ifndef INC_L1_DM_MEM
`define INC_L1_DM_MEM

module l1_dm_mem
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
) 
(
	input 											CLK,
	input                       EN,
	input 	[$clog2(DEPTH)-1:0] ADDR,
	input                       WE,
	input 	[WIDTH-1:0] 				WDATA,
	output 	[WIDTH-1:0] 				RDATA
);

	sram_sp
	#(
		.WIDTH  (WIDTH),
		.DEPTH 	(DEPTH)
	)
	mem
	(
		.WE 		(WE),
		.EN 		(EN),
		.CLK 		(CLK),
		.ADDR 	(ADDR),
		.DI 		(WDATA), 
		.DO 		(RDATA)
	);

endmodule
`endif