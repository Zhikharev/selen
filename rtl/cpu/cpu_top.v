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
	output[3:0] data_be_out,
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
wire[31:0] regD2ctrl;
wire[31:0] a_mux1;
wire[31:0] b_mux1;
wire[31:0] out_mux1;
wire s_mux1;
wire[31:0] a_mux3;
wire[31:0] b_mux3;
wire[31:0] out_mux3;
wire s_mux3;
wire[31:0] a_mux2;
wire[31:0] b_mux2;
wire[31:0] out_mux2;
wire s_mux2;
wire[31:0] a_mux4_2;
wire[31:0] b_mux4_2;
wire[31:0] out_mux4_2;
wire s_mux4_2;
wire [31:0] a_mux4;
wire [31:0] b_mux4;
wire[31:0] out_mux4;
wire s_mux4;
reg[31:0] pc;
////// end of wires of multiplecser
//// 							end of fetch stage
///// 							wires of decode 
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
wire ctrl2_mux7;
wire ctrl2_mux6;
wire ctrl2_mux5;
wire ctrl2_mux4_2;
wire ctrl2_mux4;
wire ctrl2_mux3;
wire ctrl2_mux1;
wire[1:0] ctrl2regE_cmd;
wire[3:0] ctrl2regE_alu_ctrl;
wire ctrl2regE_sign_alu;
wire[1:0]ctrl2regE_brch_type;
wire ctrl2regE_we_mem;
wire ctrl2regE_we_reg;
wire[1:0] ctrl2regE_be_mem;
wire ctrl_rubish;
////end of ctrl wires
///// wires of mux
wire[31:0] out_mux5;
wire[31:0] a_mux5;
wire[31:0] b_mux5;
wire s_mux5;

wire[31:0] out_mux7;
wire[11:0] a_mux7;
wire[11:0] b_mux7;
wire s_mux7;

wire[31:0] out_mux6;
wire[31:0] a_mux6;
wire[31:0] b_mux6;
wire s_mux6;
///// end wires of muxs
////							end of decode stage 
////							 exeqution 
wire[31:0] address;
wire regE2_mux8;
wire regE2_mux8_2;
wire regE2_mux8_3;
wire[3:0] regE2_alu_ctrl;
wire regE2_alu_sign;
wire[31:0] regE2a_bpmux2;
wire[31:0] regE2b_bpmux4;
wire[31:0] regE2b_sign_adder;
wire[31:0] regE2a_sign_adder;
wire[4:0] regE2regM_rs1;
wire[4:0] regE2regM_rs2;
wire [4:0] regE2regM_rd;
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
wire[1:0] regM2cnd;
wire [31:0] result2mem;
wire regM2regW_mux10;
wire regM2regW_cmd;
wire regM2regW_mux9;
wire[19:0] regM2regW_imm20;
wire[19:0] regM2b_mux10_imm20;
wire[4:0] regM2regW_rs1;
wire[4:0] regM2ergW_rs2;
wire[4:0] regM2regW_rd;
wire[31:0] regM2bpmux;
wire[31:0] mem2regW;

wire[31:0] a_bpmux5;
wire[31:0] b_bpmux5;
wire[31:0] out_bpmux5;
wire s_bpmux5;
////					end of mem
////					out 
wire[31:0] a_mux9;
wire[31:0] b_mux9;
wire[31:0] out_mux9;
wire s_mux9;

wire[31:0] a_mux10;
wire[31:0] b_mux10;
wire[31:0] out_mux10;
wire s_mux10;
////					end of out 
//################################### modules 
//// program counter 
always @(posedge sys_clk)
begin
	if(sys_rst) begin
		pc <= 31'b0;
	end
	else begin
		pc <= out_mux2;
	end
end
//////
reg_decode reg_decode(
	.instr_in(inst_data_in),
	.pc_in(b_mux1),//pc +4 
	.clk(sys_clk),
	.enb(hz2regD_enb),
	.flash(hz2regD_flash),
	.instr_out(regD2ctrl),
	.pc_out(regD2regE)//pc +4
);
reg_file reg_file (
	.clk(sys_clk),
	.reset(sys_reset),
	.we(we_regW2we),//1 writting is allowed
	.data_in(out_mux5),
	.adr_wrt(regD2ctrl[11:7]),
	.adr_srca(regD2ctrl[19:15]),
	.adr_srcb(regD2ctrl[24:20]),
	.out_srca(srca2regE),
	.out_srcb(srcb2regE),
	.done(done2hz)
);
cpu_ctrl cpu_ctrl(
	.fnct7(regD2ctrl[31:30]),
	.fnct(regD2ctrl[14:12]),
	.opcode(regD2ctrl[6:0]),
	.hz2ctrl(ctrl2hz),
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
	.mux7(ctrl2_mux7),
	.mux6(ctrl2_mux6),
	.mux5(ctrl2_mux5),
	.mux4(ctrl2_mux4),
	.mux4_2(s_mux4_2),
	.mux3(s_mux3),
	.cmd(ctrl2regE_cmd),
	.rubish()
);
reg_exe reg_exe(
	.srcaE(srca2regE),
	.srcbE(srcb2regE),
	.rs1E(regD2ctrl[19:15]),
	.rs2E(regD2ctrl[24:10]),
	.rdE(regD2ctrl[11:7]),
	.pcE(b_mux1),//pc+4;
	.imm20E(regD2ctrl[31:12]),
	.imm_or_adr(out_mux7),
	.s_u_alu(ctrl2regE_sign_alu),
	.alu_ctrl(ctrl2regE_alu_ctrl),
	.be_memE(cnt2regE_be_mem),
	.we_memE(cntr2regE_we_mem),
	.we_regE(ctrl2regE_we_reg),
	.brch_typeE(ctrl2regE_brch_type),
	.mux9E(ctrl2regE_mux9),
	.mux8E(ctrl2regE_mux8),
	.mux8_2E(ctrl2regE_mux8_2),
	.mux8_3E(ctrl2regE_mux_3),
	.mux10E(ctrl2regE_mux10D),
	.clk(sys_clk),
	.enbE(hz2regE_enbE),
	.flashE(hz2reg_flashE),
	.cmdE(ctrl2regE),
	
	.srcaE_out(regE2a_bpmux2),
	.srcbE_out(regE2a_bpmux4),
	.rs1E_out(regE2regM_rs1),
	.rs2E_out(regE2regM_rs2),
	.rdE_out(regE2regM_rd),
	.pcE_out(regE2a_sign_adder),//pc+4;
	.imm20E_out(regE2regM_imm20),
	.s_u_alu_out(regE2_sign_alu),
	.alu_ctrl_out(regE2_alu_ctrl),
	.be_memE_out(regE2regM_be_mem),
	.we_memE_out(regE2regM_we_mem),
	.we_regE_out(regE2regM_we_mem),
	.brch_typeE_out(regE2regM_brch_type),
	.mux9E_out(regE2regM_mux9),
	.mux8E_out(regE2_mux8),
	.mux8_2E_out(regE2_mux8_2),
	.mux8_3E_out(regE2_mux8_3),
	.mux10E_out(regE2regM_mux10),
	.cmdE_out(regE2regM_cmd),
	.imm_or_adr_out(regE2b_sign_adder)
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
	.resultM(alu2_regM_resalt),
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

	.resultM_out(regM2mem_result),
	.srcbM_out(regM2mem_srcb),
	.cndM_out(regM2brch_cnd_cnd),
	.addrM_out(regM2a_mux1),
	.rdM_out(regM2regW_rd),
	.be_memM_out(regM2regW_be_mem),
	.we_memM_out(regM2regW_we_mem),
	.we_regM_out(regM2regW_we_reg),
	.brch_typeM_out(regM2_cnd_type),
	.mux9M_out(regM2regW_mux9),
	.mux5M_out(regM2regW_mux5),
	.mux10M_out(regM2regW_mux10)
);brch_cnd(
	.brnch_typeM(regM2cnd_type),
	.cndM(regM2cnd_cnd),
	.mux1(s_mux1)
);
reg_write(
	.we_regW(regM2regW_we_reg),
	.mux9W(regM2regW_mux9),
	.resultW(regM2regW_result),
	.rdW(regM2regW_rd),
	.memW(mem2regW),
	.clk(sys_clk),
	.flashW(hz2regW_flash),
	.enbW(hz2regW_enb),
	.rs1W(regM2regW_rs1),
	.rs2W(regM2regW_rs2),
	.we_regW_out(regW2reg_we),
	.imm20(regM2regW_imm20),
	
	.mux9W_out(regW2mux9),
	.resultW_out(regW2a_mux9),
	.rdW_out(regW2reg_rd),
	.memW_out(regW2b_mux9),
	.rs1W_out(regW_rs1_out),
	.rs2W_out(regW_rs2_out),
	.imm20_out(regW2b_mux10_imm20)
);sx_2 (
	.cntr(regW2ctrl),
	.data_in(out_mux9),
	.data_out(a_mux10)
);
hazard_unit(
	.reset(sys_rst),
	.cmd_inD(ctrl2regE_cmd),
	.cmd_inE(regE2regM_cmd),
	.cmd_inM(regM2regW_cmd),
	.cmd_inW(regW2_out),
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
	.rdW(regW_out),
	.we_regE(regE2regM_we_reg),
	.we_regW(regW_out),
	.we_regM(regM2regW_we_reg),
	.mux1(s_mux1),
	
	.bp1M(s_bpmux1),
	.bp2W(s_bpmux2),
	.bp3M(s_bpmux3),
	.bp4W(s_bpmux4),
	.mux2(s_mux2),
	.hzu2cntr(hz2ctrl),
	
	.flashD(hz2flashD),
	.flashE(hz2flashE),
	.flashM(hz2flashM),
	.flashW(hz2flashW),
			
	.enbD(hz2enbD),
	.endE(hz2enbE),
	.enbM(hz2enbM),
	.enbW(hz2enbW)
);
///// ############### area with pc (fetch)
assign b_mux1 = out_mux4 + out_mux4_2; //sign adder
assign b_mux3 = {{11{regD2ctrl[31]}},regD2ctrl[31],regD2ctrl[19:12],regD2ctrl[20],regD2ctrl[30:21]};//sing extension for 20 imm
assign a_mux2 = out_mux3;
assign b_mux2 = pc;
assign b_mux4_2 = pc;
assign a_mux4_2 = srca2regE;////
assign a_mux4 = sxD2mux4;
assign b_mux4 = 31'b100;
assign a_mux1 = address;
assign inst_addr_out = pc;
assign out_mux1 = s_mux1 ? b_mux1 : a_mux1; // mux1
assign out_mux2 = s_mux2 ? b_mux2 : a_mux2; // mux2
assign out_mux3 = s_mux3 ? b_mux3 : a_mux3; // mux3
assign out_mux4_2 = s_mux4_2 ? b_mux4_2 : a_mux4_2; // mux4_2
assign out_mux4 = s_mux4 ? b_mux4 : a_mux4; // mux4

//// ################ end of fetch
//// ################ decode 
/////begining of sign extenshion 

assign a_mux6 = {{19{regD2ctrl}},regD2ctrl[31],regD2ctrl[7],regD2ctrl[31:25],regD2ctrl[11:8]};
assign b_mux6 = {{20{regD2ctrl}},regD2ctrl[31:25],regD2ctrl[11:7]};
assign b_mux7 = out_mux6;
//// sign extension end 

assign out_mux6 = (s_mux6)? b_mux6:a_mux6;
assign out_mux5 = (s_mux5)?b_mux5:a_mux5;
assign out_mux7 = (s_mux7)? {{19{b_mux7[12]}},b_mux7}:{{19{a_mux7[12]}},a_mux7};///mux end sign extension
//// ################ end of decode
/////################ exe phase 
assign out_mux8 = s_mux8 ? b_mux8 : a_mux8; // mux8
assign out_mux8_2 = s_mux8_2 ? b_mux8_2 : a_mux8_2; // mux8_2
assign out_mux8_3 = s_mux8_3 ? b_mux8_3 : a_mux8_3; // mux8_3
assign out_bpmux1 = s_bpmux1 ? b_bpmux1 : a_bpmux1; // bpmux1
assign out_bpmux2 = s_bpmux2 ? b_bpmux2 : a_bpmux2; // bpmux2
assign out_bpmux3 = s_bpmux3 ? b_bpmux3 : a_bpmux3; // bpmux3
assign out_bpmux4_2 = s_bpmux4 ? b_bpmux4 : a_bpmux4; // bpmux4

assign a_bpmux1 = regM2mem_result;
assign b_bpmux1 = out_bpmux2;
assign a_bpmux2 = regE2a_bpmux2;
assign b_bpmux2 = out_mux10;
assign b_bpmux4 = out_mux10;
assign a_bpmux4 = regE2b_bpmux4;
assign a_bpmux3 = regM2mem_result;
assign b_bpmux3 = out_bpmux4;
assign a_mux8_2 = out_bpmux1;
assign b_mux8_2 = {regE2regM_imm20,{11{1'b0}}};
assign a_mux8 = out_bpmux3;
assign b_mux8 = regE2b_sign_adder;
assign a_mux8_3 = out_mux8;
assign b_nux8_3 = regE2b_sign_adder;

assign address = regE2a_sign_adder + regE2b_sign_adder;////address adder

//// ################ end of exe
//// ################ mem
assign out_bpmux5 = (s_bpmux5)?b_bpmux5:a_bpmux5;
assign data_data_out = out_bpmux5;
assign out_mux9 = (s_mux9)? b_mux9:a_mux9;
assign a_mux9 = regW2a_mux9;
assign b_mux9 = regW2b_mux9;
assign b_mux10 = {regW2b_mux10_imm20,{11{1'b1}}};
assign out_mux10 = (s_mux10)? b_mux10:a_mux10;
//// ################ end of mem

endmodule
