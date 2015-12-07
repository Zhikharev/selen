/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: cpu_top.v
# Descriptions:
# 	there are connections betwine all inner blocks of cpu
###########################################################
*/

module cpu_top (
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
	//system
	input sys_clk,
	input sys_rst
);

//all wires  ###################################################### 
//// 							fetch phase 

///wires of multiplecsers
/////wires for mem block
wire s_mux1;
wire s_mux2;
wire s_mux3;
wire s_mux4;
wire s_mux4_2;
wire[31:0] mem_block2regD_inst;
wire[31:0] inst_data_out;
wire[31:0] regM2a_mux1;
wire hz2enbD;
wire hz2flashD;
wire hz2ctrl;
////// end of wires of multiplecser
//// 							end of fetch stage
///// 							wires of decode 
wire hz2flashE;
wire[31:0] srca2regE;
wire[31:0] srcb2regE;
wire ctrl2hz;
wire[2:0] ctrl2regE_sx_ctrl;
wire[31:0] sxD2mux4;
////ctrl wires 
wire ctrl2regE_mux10;
wire ctrl2regE_mux9;
wire ctrl2regE_mux8_3;
wire ctrl2regE_mux8_2;
wire ctrl2regE_mux8;
//wire ctrl2_mux5;
//wire ctrl2_mux4_2;
//wire ctrl2_mux4;
//wire ctrl2_mux3;
//wire ctrl2_mux1;
wire[1:0] ctrl2regE_cmd;
wire[3:0] ctrl2regE_alu_ctrl;
wire ctrl2regE_alu_sign;
wire[1:0]ctrl2regE_brch_type;
wire ctrl2regE_we_mem;
wire ctrl2regE_we_reg;
wire[1:0] ctrl2regE_be_mem;
wire ctrl_rubish;
wire[31:0] regD2regE_pc;
wire[31:0] regD2ctrl;
wire reg2hz;
////end of ctrl wires
///// wires of mux
wire[31:0] out_mux5;
wire[31:0] a_mux5;
wire[31:0] b_mux5;
wire s_mux5;

wire[31:0] out_mux7;
//wire[11:0] a_mux7;
wire[31:0] b_mux7;
wire s_mux7;

wire[31:0] out_mux6;
wire[31:0] a_mux6;
wire[31:0] b_mux6;
wire s_mux6;
///// end wires of muxs
////							end of decode stage 
////							 exeqution 
wire hz2enbE;

wire[31:0] address;
wire[2:0] regE2regM_sx;
wire regE2_mux8;
wire regE2_mux8_2;
wire regE2_mux8_3;
wire[3:0] regE2_alu_ctrl;
wire regE2_alu_sign;
wire[31:0] regE2a_bpmux2;
wire[31:0] regE2a_bpmux4;
wire[31:0] regE2b_sign_adder;
wire[31:0] regE2a_sign_adder;
wire[4:0] regE2regM_rs1;
wire[4:0] regE2regM_rs2;
wire [4:0] regE2regM_rd;
wire[19:0] regE2regM_imm20;
wire[31:0] alu2regM_result;
wire[1:0] alu2regM_cnd;
wire[2:0] regE2ergM_sx;
wire regE2regM_we_reg;

///muxs for exeqution stage 
wire[31:0] out_mux8;
wire[31:0] a_mux8;
wire[31:0] b_mux8;
wire s_mux8;

wire[31:0] out_mux8_2;
wire[31:0] a_mux8_2;
wire[31:0] b_mux8_2;
wire s_mux8_2;

wire[31:0] out_mux8_3;
wire[31:0] a_mux8_3;
wire[31:0] b_mux8_3;
wire s_mux8_3;
///end muxs of exeqution stage 
/// forwardinr's mux
wire[31:0] out_bpmux1;
wire[31:0] a_bpmux1;
wire[31:0] b_bpmux1;
wire s_bpmux1;

wire[31:0] out_bpmux2;
wire[31:0] a_bpmux2;
wire[31:0] b_bpmux2;
wire s_bpmux2;

wire[31:0] out_bpmux3;
wire[31:0] a_bpmux3;
wire[31:0] b_bpmux3;
wire s_bpmux3;

wire[31:0] out_bpmux4;
wire[31:0] a_bpmux4;
wire[31:0] b_bpmux4;
wire s_bpmux4;
//// end of forwarding
//// regE2regM
wire[1:0] regE2regM_be_mem;
wire regE2regM_we_mem;
wire regE2regM_mux10;
wire regE2regM_mux9;
wire[1:0] regE2regM_brch_type;
wire[1:0] regE2regM_cmd;
////						end of exe
//// 						memory stage 
wire hz2enbW;
wire hz2flashM;
wire[1:0] regM2cnd;
wire [31:0] result2mem;
wire regM2regW_mux10;
wire[1:0] regM2regW_cmd;
wire regM2regW_mux9;
wire[19:0] regM2regW_imm20;
wire[19:0] regM2b_mux10_imm20;
//wire regM2regW_mux10;
wire[4:0] regM2regW_rs1;
wire[4:0] regM2ergW_rs2;
wire[4:0] regM2regW_rd;
wire[31:0] regM2bpmux;
wire[31:0] mem2regW;
wire[31:0] regM2mem_result;
wire[1:0] regM2_cnd_type;
wire[1:0] regM2brch_cnd;
//wire regM2mem_we_mem;
//wire[1:0] regM2mem_be_mem;

wire[31:0] a_bpmux5;
wire[31:0] b_bpmux5;
wire[31:0] out_bpmux5;
wire s_bpmux5;
wire[2:0] regM2regW_sx;
wire[4:0] regM2regW_rs2;
wire hz2enbM;
////					end of mem
////					out 
wire[31:0] a_mux9;
wire[31:0] b_mux9;
wire[31:0] out_mux9;
wire s_mux9;
wire hz2flashW;

wire[31:0] a_mux10;
wire[31:0] b_mux10;
wire[31:0] out_mux10;
wire s_mux10;
wire[2:0] regW2sx;
wire regW2out_we_reg;
wire[4:0] regW2out_rd;
wire[4:0] regW2out_rs2;
wire[4:0] regW2out_rs1;
wire[1:0] regW2out_cmd;
wire[1:0] regW2out;
wire[31:0] regW2a_mux9;
wire[31:0] regW2b_mux9;
wire[4:0] regW2reg_rd;
wire[4:0] regW_rs2W_out;
wire[19:0] regW2b_mux10_imm20;

////					end of out 
//################################### modules 
///mem_block
wire[31:0] mem_block2regD_pc;
mem_block mem_block (
	.rst(sys_rst),
	.clk(sys_clk),
	
	.mux1(s_mux1),
	.mux2(s_mux2),
	.mux3(s_mux3),
	.mux4(s_mux4),
	.mux4_2(s_mux4_2),
	.stall(inst_stall_in),
	
	.ack_in(inst_ack_in),
	.inst_in(inst_data_in),
	.inst_out(mem_block2regD_inst),
	.imm_20({{11{regD2ctrl[31]}},regD2ctrl[31],regD2ctrl[19:12],regD2ctrl[20],regD2ctrl[30:21]}),
	.imm_12(out_mux7),
	.reg_in(srca2regE),
	.brch_address(regM2a_mux1),

	.inst_addr(inst_addr_out),
	.cyc(inst_cyc_out),
	.stb(inst_stb_out),
	.pc_next_out(mem_block2regD_pc)
);

//////
reg_decode reg_decode(
	.instr_in(inst_data_in),
	.pc_in(mem_block2regD_pc),//pc +4 
	.clk(sys_clk),
	.enb(hz2enbD),
	.flash(hz2flashD),
	.instr_out(regD2ctrl),
	.pc_out(regD2regE_pc)//pc +4
);
reg_file reg_file (
	.clk(sys_clk),
	.reset(sys_rst),
	.we(regW2out_we_reg),//1 writting is allowed
	.data_in(out_mux5),
	.adr_wrt(regW2out_rd),
	.adr_srca(regD2ctrl[19:15]),
	.adr_srcb(regD2ctrl[24:20]),
	.out_srca(srca2regE),
	.out_srcb(srcb2regE),
	.done(reg2hz)
);
cpu_ctrl cpu_ctrl(
	.rst(sys_rst),
	.fnct7(regD2ctrl[31:30]),
	.fnct(regD2ctrl[14:12]),
	.opcode(regD2ctrl[6:0]),
	.hz2ctrl(hz2ctrl),
	.be_mem(ctrl2regE_be_mem),
	.we_mem(ctrl2regE_we_mem),
	.we_reg(ctrl2regE_we_reg),
	.brn_type(ctrl2regE_brch_type),
	.sx_cntl(ctrl2regE_sx_ctrl),
	.alu_cntr(ctrl2regE_alu_ctrl),
	.alu_s_u(ctrl2regE_alu_sign),
	.mux10(ctrl2regE_mux10),
	.mux9(ctrl2regE_mux9),
	.mux8(ctrl2regE_mux8),
	.mux8_2(ctrl2regE_mux8_2),
	.mux8_3(ctrl2regE_mux8_3),
	.mux7(s_mux7),
	.mux6(s_mux6),
	.mux5(s_mux5),
	.mux4(s_mux4),
	.mux4_2(s_mux4_2),
	.mux3(s_mux3),
	.cmd(ctrl2regE_cmd),
	.rubish()
);
reg_exe reg_exe(
	.srcaE(srca2regE),
	.srcbE(srcb2regE),
	.rs1E(regD2ctrl[19:15]),
	.rs2E(regD2ctrl[24:20]),
	.rdE(regD2ctrl[11:7]),
	.pcE(regD2regE_pc),
	.imm20E(regD2ctrl[31:12]),
	.imm_or_addr(out_mux7),
	.s_u_alu(ctrl2regE_alu_sign),
	.alu_ctrl(ctrl2regE_alu_ctrl),
	.be_memE(ctrl2regE_be_mem),
	.we_memE(ctrl2regE_we_mem),
	.we_regE(ctrl2regE_we_reg),
	.brch_typeE(ctrl2regE_brch_type),
	.mux9E(ctrl2regE_mux9),
	.mux8E(ctrl2regE_mux8),
	.mux8_2E(ctrl2regE_mux8_2),
	.mux8_3E(ctrl2regE_mux8_3),
	.mux10E(ctrl2regE_mux10),
	.clk(sys_clk),
	.enbE(hz2enbE),
	.flashE(hz2flashE),
	.cmdE(ctrl2regE_cmd),
	.sx_2E_ctrl(ctrl2regE_sx_ctrl),
	
	.srcaE_out(regE2a_bpmux2),
	.srcbE_out(regE2a_bpmux4),
	.rs1E_out(regE2regM_rs1),
	.rs2E_out(regE2regM_rs2),
	.rdE_out(regE2regM_rd),
	.pcE_out(regE2a_sign_adder),//pc+4;
	.imm20E_out(regE2regM_imm20),
	.s_u_alu_out(regE2_alu_sign),
	.alu_ctrl_out(regE2_alu_ctrl),
	.be_memE_out(regE2regM_be_mem),
	.we_memE_out(regE2regM_we_mem),
	.we_regE_out(regE2regM_we_reg),
	.brch_typeE_out(regE2regM_brch_type),
	.mux9E_out(regE2regM_mux9),
	.mux8E_out(s_mux8),
	.mux8_2E_out(s_mux8_2),
	.mux8_3E_out(s_mux8_3),
	.mux10E_out(regE2regM_mux10),
	.cmdE_out(regE2regM_cmd),
	.imm_or_addr_out(regE2b_sign_adder),
	.sx_2E_ctrl_out(regE2regM_sx)
);
alu alu (
	.srca(out_mux8_2),
	.srcb(out_mux8_3),
	.cntl(regE2_alu_ctrl),
	.not_s(regE2_alu_sign),
	.result(alu2regM_result),
	.cnd(alu2regM_cnd)
);
reg_mem reg_mem(
	.resultM(alu2regM_result),
	.srcbM(regE2a_bpmux4),
	.cndM(regE2regM_cmd),
	.addrM(address),
	.be_memM(regE2regM_be_mem),
	.we_memM(regE2regM_we_mem),
	.we_regM(regE2regM_we_reg),
	.brch_typeM(regE2regM_brch_type),
	.mux9M(regE2regM_mux9),
	.mux10M(regE2regM_mux10),
	.clk(sys_clk),
	.enbM(hz2enbM),
	.flashM(hz2flashM),
	.rs1M(regE2regM_rs1),
	.rs2M(regE2regM_rs2),
	.rdM(regE2regM_rd),
	.cmdM(regE2regM_cmd),
	.imm20M(regE2regM_imm20),
	.sx_2M_ctrl(regE2regM_sx),
	
	.resultM_out(regM2mem_result),
	.srcbM_out(regM2bpmux),
	.cndM_out(regM2brch_cnd),
	.addrM_out(regM2a_mux1),
	.rs1M_out(regM2regW_rs1),
	.rs2M_out(regM2regW_rs2),
	.rdM_out(regM2regW_rd),
	.be_memM_out(data_be_out),// data_be_out
	.we_memM_out(data_we_out),// data_we_out
	.we_regM_out(regM2regW_we_reg),
	.brch_typeM_out(regM2_cnd_type),
	.mux9M_out(regM2regW_mux9),
//	.mux5M_out(regM2regW_mux5),
	.mux10M_out(regM2regW_mux10),
	.cmdM_out(regM2regW_cmd),
	.imm20M_out(regM2regW_imm20),
	.sx_2M_ctrl_out(regM2regW_sx)
	);
brch_cnd brch_cnd(
	.brnch_typeM(regM2_cnd_type),
	.cndM(regM2brch_cnd),
	.mux1(s_mux1),
	.rst(sys_rst)
);
reg_write reg_write(
	.we_regW(regM2regW_we_reg),
	.mux9W(regM2regW_mux9),
	.mux10W(regM2regW_mux10),
	.resultW(regM2mem_result),
	.rdW(regM2regW_rd),
	.memW(mem2regW),
	.clk(sys_clk),
	.flashW(hz2flashW),
	.enbW(hz2enbW),
	.rs1W(regM2regW_rs1),
	.rs2W(regM2regW_rs2),
	.imm20W(regM2regW_imm20),
	.cmdW(regM2regW_cmd),
	.sx_2W_ctrl(regM2regW_sx),
	
	.we_regW_out(regW2out_we_reg),
	.mux9W_out(s_mux9),
	.mux10W_out(s_mux10),
	.resultW_out(regW2a_mux9),
	.rdW_out(regW2out_rd),
	.memW_out(regW2b_mux9),
	.rs1W_out(regW2out_rs1),
	.rs2W_out(regW2out_rs2),
	.imm20W_out(regW2b_mux10_imm20),
	.cmdW_out(regW2out_cmd),
	.sx_2W_ctrl_out(regW2sx)
);
sx_2 sx_2 (
	.ctrl(regW2sx),
	.data_in(out_mux9),
	.data_out(a_mux10)
);
hazard_unit hazard_unit(
	.reset(sys_rst),
	.cmd_inD(ctrl2regE_cmd),
	.cmd_inE(regE2regM_cmd),
	.cmd_inM(regM2regW_cmd),
	.cmd_inW(regW2out_cmd),
	.done_in(reg2hz),
	.rs1D(regD2ctrl[19:15]),
	.rs2D(regD2ctrl[24:20]),
	.rs1E(regE2regM_rs1),
	.rs2E(regE2regM_rs2),
	.rs1M(regE2regM_rs1),
	.rs2M(regE2regM_rs2),
	.rs1W(regE2regM_rs1),
	.rs2W(regE2regM_rs2),
	.rdD(regD2ctrl[11:7]),
	.rdE(regE2regM_rd),
	.rdM(regM2regW_rd),
	.rdW(regW2out_rd),
	.we_regE(regE2regM_we_reg),
	.we_regW(regW2out_we_reg),
	.we_regM(regM2regW_we_reg),
	.mux1(s_mux1),
	.stall_in(inst_stall_in),
	.ack_in(inst_ack_in),
	.mem_ctrl(mem_ctrl2hz),
	
	.bp1M(s_bpmux1),
	.bp2W(s_bpmux2),
	.bp3M(s_bpmux3),
	.bp4W(s_bpmux4),
	.bp5M(s_bpmux5),
	.mux2(s_mux2),
	.hz2ctrl(hz2ctrl),
	
	.flashD(hz2flashD),
	.flashE(hz2flashE),
	.flashM(hz2flashM),
	.flashW(hz2flashW),
			
	.enbD(hz2enbD),
	.enbE(hz2enbE),
	.enbM(hz2enbM),
	.enbW(hz2enbW)
);
///// ############### area with pc (fetch)




//// ################ end of fetch
//// ################ decode 
/////begining of sign extenshion 

assign a_mux6 = {{19{regD2ctrl}},regD2ctrl[31],regD2ctrl[7],regD2ctrl[31:25],regD2ctrl[11:8]};
assign b_mux6 = {{20{regD2ctrl}},regD2ctrl[31:25],regD2ctrl[11:7]};
assign b_mux7 = out_mux6;
//// sign extension end 

assign out_mux6 = (s_mux6)?b_mux6:a_mux6;
assign out_mux5 = (s_mux5)?b_mux5:a_mux5;
assign a_mux5 = regD2regE_pc;
assign b_mux5 = out_mux10;
assign out_mux7 = (s_mux7)?b_mux7:{{19{regD2ctrl[31]}},regD2ctrl[31:20]};///mux end sign extension//a_mux7

//// ################ end of decode
/////################ exe phase
assign out_mux8 = s_mux8 ? b_mux8 : a_mux8; // mux8
assign out_mux8_2 = s_mux8_2 ? b_mux8_2 : a_mux8_2; // mux8_2
assign out_mux8_3 = s_mux8_3 ? b_mux8_3 : a_mux8_3; // mux8_3
assign out_bpmux1 = s_bpmux1 ? b_bpmux1 : a_bpmux1; // bpmux1
assign out_bpmux2 = s_bpmux2 ? b_bpmux2 : a_bpmux2; // bpmux2
assign out_bpmux3 = s_bpmux3 ? b_bpmux3 : a_bpmux3; // bpmux3
assign out_bpmux4 = s_bpmux4 ? b_bpmux4 : a_bpmux4; // bpmux4
assign out_bpmux5 = (s_bpmux5)?b_bpmux5:a_bpmux5;//bpmux5

assign a_bpmux1 = regM2mem_result;
assign b_bpmux1 = out_bpmux2;
assign a_bpmux2 = regE2a_bpmux2;
assign b_bpmux2 = out_mux10;
assign b_bpmux4 = out_mux10;
assign a_bpmux4 = regE2a_bpmux4;
assign a_bpmux3 = regM2mem_result;
assign b_bpmux3 = out_bpmux4;
assign a_mux8_2 = out_bpmux1;
assign b_mux8_2 = {regE2regM_imm20,{11{1'b0}}};
assign a_mux8 = out_bpmux3;
assign b_mux8 = regE2b_sign_adder;
assign a_mux8_3 = out_mux8;
assign b_mux8_3 = regE2b_sign_adder;

assign address = regE2a_sign_adder + regE2b_sign_adder;////address adder

//// ################ end of exe
//// ################ mem

assign a_bpmux5 = regM2bpmux;
assign b_bpmux5 = out_mux10;
assign data_data_out = out_bpmux5;//data_data_out
assign out_mux9 = (s_mux9)? b_mux9:a_mux9;
assign a_mux9 = regW2a_mux9;
assign b_mux9 = regW2b_mux9;
assign b_mux10 = {regW2b_mux10_imm20,{11{1'b1}}};
assign out_mux10 = (s_mux10)? b_mux10:a_mux10;
//// ################ end of mem
assign mem2regW = data_data_in;//data_data_in
assign data_addr_out = regM2mem_result; //data_addr_out
//assign data_we_out = regM2mem_we_mem;
endmodule
