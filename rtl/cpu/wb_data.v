module wb_data(
	//wish bone 
	output stb,
	output we,
	output[1:0] be,
	output[31:0] addr_out,
	output[31:0] data_out,
	input ack,
	input stall,
	input[31:0] data_in,
	input clk,
	input rst,
	/// terminals from cpu
	input[31:0] data_in_cpu,
	input [31:0] addr_in_cpu,
	input sw,
	input lw,
	input[1:0] be_cpu,
	input we_cpu
);


endmodule
