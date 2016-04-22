// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_dm_mem.v
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
	input   [WIDTH/8-1:0]       WBE,
	input 	[WIDTH-1:0] 				WDATA,
	output 	[WIDTH-1:0] 				RDATA
);

	wire [WIDTH/8-1:0] we;

	assign we = WBE & {WIDTH/8{WE}};

`ifdef PROTO
	// Xilinx ISE sram IP-core
	sram_sp_be_256x256
`else
	sram_sp_be
	#(
		.WIDTH  (WIDTH),
		.DEPTH 	(DEPTH)
	)
`endif
	mem
	(
		.clka 	(CLK),
		.ena 		(EN),
		.wea 		(we),
		.addra 	(ADDR),
		.dina 	(WDATA),
		.douta 	(RDATA)
	);

endmodule
`endif