module top (
	//instraction
	output inst_cyc_out,
	output inst_stb_out,
	output[31:0] inst_addr_out,
	input inst_akn_in,
	input[31:0] inst_data_in,
	input inst_stall_in,
	//data
	output data_stb_out,
	output[31:0] data_addr_out,	
	output data_we_out,
	output[3:0] data_be_out,
	input data_akn_in,
	output[31:0] data_addr_out,
	input[31:0] data_data_in,
	//system
	input sys_clk,
	input sys_rst
);



endmodule
