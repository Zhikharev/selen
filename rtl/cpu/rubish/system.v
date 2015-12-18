module system (
	//instruction 
	output inst_cyc_out,
	output inst_stb_out,
	output[31:0] inst_addr_out,
	input inst_ack_in,
	input[31:0] inst_data_in,
	input inst_stall_in,
	//data
	output data_stb_out,
	output data_we_out,
	output[1:0] data_be_out,
	input data_ack_in,
	output[31:0] data_addr_out,
	output[31:0] data_data_out,
	input[31:0] data_data_in,
	input data_stall_in,
	//system
	input sys_clk,
	input sys_rst
);

fifo fifo_pc #(
	DEPTH = 5,
	SIZE	= 32
)
(
	.clk(sys_clk),
	.wr_en(fifo_pc_wr_en),
	.din(fifo_pc_data_in),
	.rd_en(fifo_pc_rd_en),
	.dout(fifo_pc_data_out),
	.empty(fifo_pc_empty),
	.full(fifo_pc_full)
);
fifo fifo_inst #(
	DEPTH = 5,
	SIZE	= 32
)
(
	.clk(sys_clk),
	.wr_en(fifo_inst_wr_en),
	.din(fifo_inst_data_in),
	.rd_en(fifo_inst_rd_en),
	.dout(fifo_inst_data_out),
	.empty(fifo_inst_empty),
	.full(fifo_inst_full)
);

fifo fifo_st #(
	DEPTH = 5,
	SIZE	= 32
)
(
	.clk(sys_clk),
	.wr_en(fifo_st_wr_en),
	.din(fifo_st_data_in),
	.rd_en(fifo_st_rd_en),
	.dout(fifo_st_data_out),
	.empty(fifo_st_empty),
	.full(fifo_st_full)
);


