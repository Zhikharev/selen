// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1_reg_mem.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------
`ifndef INC_L1_REG_MEM
`define INC_L1_REG_MEM

module 
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
) 
l1_reg_mem
(
	input 											clk,
	input 											rst_n,
	input 	[$clog(DEPTH)-1:0] 	raddr,
	output 	[WIDTH-1:0] 				rdata,
	input                       wen,
	input 	[$clog(DEPTH)-1:0] 	waddr,
	input 	[WIDTH-1:0] 				wdata,
	input 	[(WIDTH/32)-1:0] 		wbe
);


	reg  [WIDTH-1:0] mem [DEPTH];
	wire [WIDTH-1:0] mask_data;

	assign rdata = mem[raddr];

	genvar i;
	generate 
		for(i = 0; i < WIDTH/8; i = i + 1) begin
			assign mask_data[i*8+:8] = (wbe[i]) ? wdata[i*8+:8] : mem[waddr][i*8+:8]; 
		end
	endgenerate

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			for(integer i = 0; i < DEPTH; i = i + 1) begin
				mem[i] <= 0;
			end
		end
		else begin
			if(wval) mem[waddr] <= mask_data;
		end
	end


endmodule
`endif