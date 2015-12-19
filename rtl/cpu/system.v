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
///side of instraction wishbone interface
wire cpu2wbi_brnch;
wire [31:0] cpu2wbi_pc;
wire[31:0] cpu2wbi_pc_next_in;
wire[31:0] wbi2cpu_pc_next_out;
wire cpu2wbi_whait;
wire[31:0] wbi2cpu_inst;
wire wbi2cpu_stall;
wire wbi2cpu_pc_ctrl;
//wire of data wishbone interface side of cpu
wire[31:0] cpu2wbd_data_in;
wire[31:0] cpu2wbd_addr_in;
wire cpu2wbd_sw;
wire cpu2wbd_lw;
wire cpu2wbd_we;
wire[1:0] cpu2wbd_be;

wd_inst wb_inst (
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

	.brnch(cpu2wbi_brnch),
	.pc(cpu2wbi_pc),
	.pc_next_in(cpu2wbi_pc_next_in),
	.pc_next_out(wbi2cpu_pc_next_out),
	.whait(cpu2wbi_whait),
	.inst(wbi2cpu_inst),
	.stall(wbi2cpu_stall),// fifo is empty 
	.pc_ctrl(wbi2cpu_pc_ctrl)
);

wb_data wb_data(
	//wish bone 
	.stb(data_stb_out),
	.we(data_we_out),
	.be(data_be_out),
	.addr_out(data_addr_out),
	.data_out(data_data_out),
	.ack(data_ack_in),
	.stall(data_stall_in),
	.data_in(data_data_in),
	.clk(sys_clk),
	.rst(sys_rst),
	/// terminals from cpu
	.data_in_cpu(cpu2wbd_data_in),
	.addr_in_cpu(cpu2wbd_addr_in),
	.sw(cpu2wbd_sw),
	.lw(cpu2wbd_lw),
	.be_cpu(cpu2wbd_be),
	.we_cpu(cpu2wbd_we)
);
cpu_top cpu_top(
	.inst_out(cpu2wbi_pc),//address of instraction
	.pc_next_out(cpu2wbi_pc_next_in),
	.brch_out(cpu2wbi_brnch),
	.sw_out(cpu2wbd_sw),
	.lw_out(cpu2wbd_lw),
	.whait_out(cpu2wbi_whait),
	.inst_in(wbi2cpu_inst),//instractoin from mem
	.data_in(cpu2wbd_data_in),//data from mem
	.data_out(), // data for store instr
	.addr_out(cpu2wbd_addr_in), // address for load commands 
	.stall_in(wbi2cpu_stall),
	.pc_ctrl(wbi2cpu_pc_ctrl),
	.pc_next_in(wbi2cpu_pc_next_out),
	.data_we_out(cpu2wbd_we),
	.data_be_out(cpu2wbd_be),
	.sys_rst(sys_rst),
	.sys_clk(sys_clk)
);

endmodule
