module system(
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
cpu_top cpu (
	.inst_out(cpu2wbi_pc),//address of instraction
	.pc_next_out(cpu2wbi_pc_next),
	.brch_out(cpu2wbi_brch),
	.sw_out(cpu2wbd_sw),
	.lw_out(cpu2wbd_lw),
	.whait_out(cpu2wbd_whait),
	.inst_in(wbi2cpu_inst),//instractoin from mem
	.data_in(wbd2cpu_data),//data from mem
	.data_out(cpu2wbd_data), // data for store instr
	.addr_out(cpu2wbd_addr), // address for load commands 
	.stall_in(sys2cpu_stall),
	.pc_ctrl(wbi2cpu_pc_ctrl),
	.ben(cpu2wbi_ben)
);
wd_inst wb_inst(
	//wb interface
	.stb(inst_stb_out),
	.cyc(inst_cyc_out),
	.wb_addr(inst_addr_out),
	.wb_stall(inst_stall_in),
	.ack(inst_ack_in),
	.wb_inst(inst_data_in),
	.rst(sys_rst),
	.clk(sys_clk),
	//terminals form cpu
	.brnch(cpu2wdi_brnch),
	.pc(cpu2wbi_pc),
	.pc_next_in(cpu2wbi_pc_next),
	.pc_next_out(wbi2cpu_pc_next),
	.whait(cpu2wbi_whait),
	.inst(wbi2cpu_inst),
	.stall(wbi_stall),
	.pc_whait(wbi2cpu_pc_ctrl)
);
wb_data wb_data(
	.data_in(data_data_in),
	.addr2mem(data_addr_out),
	.data_out(data_data_out),
	.sw(cpu2wbd_sw),
	.lw(cpu2wbd_lw),
	.clk(sys_clk),
	.rst(sys_rst),
	.stb(data_stb_out),
	.ack(data_ack_in),
	.stall(data_stall_in)
	.
);

endmodule
