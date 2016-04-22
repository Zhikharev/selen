// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_reg_ld_mem.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_REG_LD_MEM
`define INC_L1_REG_LD_MEM

module l1_reg_ld_mem
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
)
(
	input 											clk,
	input 											rst_n,
	input 	[$clog2(DEPTH)-1:0] raddr,
	output 	[WIDTH-1:0] 				rdata,
	input                       wen,
	input 	[$clog2(DEPTH)-1:0] waddr,
	input 	[WIDTH-1:0] 				wdata
);

	reg  [WIDTH-1:0] mem [DEPTH];

	assign rdata = mem[raddr];

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			for(integer i = 0; i < DEPTH; i = i + 1) begin
				mem[i] <= 0;
			end
		end
		else begin
			if(wen) mem[waddr] <= wdata;
		end
	end

endmodule
`endif