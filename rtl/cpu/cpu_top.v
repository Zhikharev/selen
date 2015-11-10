module top (
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
	input[31:0] data_data_in,
	//system
	input sys_clk,
	input sys_rst
);

//// fetch phase 
///wires of multiplecsers
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
////// end of wires of multiplecser
assign b_mux1 = out_mux4 + out_mux4_2; //sign adder
assign b_mux3 = {{11{inst_data_in[31]}},inst_data_in[31],instr_data_in[19:12],inst_data_in[20],inst_data_in[30:21]]};//sing extension for 20 imm
reg[31:0] pc;
always @(posedge clk)
begin
	if(sys_rst) begin
		pc <= 31'b0;
	end
	else begin
		pc <= out_mux2;
	end
end

assign a_mux2 = out_mux3;
assign b_mux2 = pc;
assign b_mux4_2 = pc;
assign a_mux4_2 = srca2regE;////
assign a_mux4 = sxD2mux4;
assign b_mux4 = 31'b100;
assign a_mux1 = addr2mux1;
assign inst_addr_out = pc;
assign out_mux1 = s_mux1 ? b_mux1 : a_mux1 // mux1
assign out_mux2 = s_mux2 ? b_mux2 : a_mux2 // mux2
assign out_mux3 = s_mux3 ? b_mux3 : a_mux3 // mux3
assign out_mux4_2 = s_mux4_2 ? b_mux4_2 : a_mux4_2 // mux4_2
assign out_mux4 = s_mux4 ? b_mux4 : a_mux4 // mux4

assign s_mux4_2 = cntr2_mux4_2;
assign s_mux4 = cntr2_mux4;
assign s_mux3 = cntr2_mux3;
assign s_mux2 = hz2_mux2;
assign s_mux1 = cntr2_mux1;

reg_decode(
	.instr_in(inst_data_in),
	.pc_in(b_mux1),//pc +4 
	.clk(sys_clk),
	.enb(hz2regD_enbD)
	.flash(fl_hz2regD)
	.instr_out(regD2ctrl)
	.pc_out(regD2regE)//pc +4
);
////// end of fetch

//// decode phase 
///wires of decode 
wire[31:0] srca2regE;
wire[31:0] srcb2regE;

wire[31:0] out_mux5;
wire[31:0] a_mux5;
wire[31:0] b_mux5;
wire s_mux5;

wire[31:0] out_mux7;
wire[31:0] a_mux7;
wire[31:0] b_mux7;
wire s_mux7;

wire[31:0] out_mux6;
wire[31:0] a_mux6;
wire[31:0] b_mux6;
wire s_mux6;
// end wires of decode 
/////begining of sign extenshion 
assign a_mux ={{19{inst_data_in[31]}},inst_data_in[31:20]};///sign extension
assign b_mux = out_mux6;
assign a_mux6 = {{19{inst_data_in}},instr_data_in[31],inst_data_in[7],inst_data_in[31:25],inst_data_in[11:8]};
assign b_mux6 = {{20{inst_data_in}},inst_data_in[31:25],inst_data_in[11:7]};
//// sign extension end 
assign out_mux6 = (s_mux6) b_mux6:a_mux6;
assign out_mux5 = (s_mux5) b_mux5:a_mux5;
assign out_mux7 = (s_mux7) b_mux7:a_mux7;

reg_file (
	.clk(sys_clk),
	.reset(sys_reset),
	.we(we_regW2we),//1 writting is allowed
	.data_in(out_mux5),
	.adr_wrt(inst_data_in[11:7]),
	.adr_srca(inst_data_in[19:15]),
	.adr_srcb(inst_data_in[24:20]),
	.out_srca(srca2regE),
	.out_srcb(srcb2regE),
	.done(daone2hz)
);
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
reg_exe(
	.srcaD(srca2regE),
	.srcbD(srcb2regE),
	.rs1D(inst_data_in[19:15]),
	.rs2D(inst_data_in[24:10]),
	.rdD(inst_data_in[11:7]),
	.pcD(b_mux1),//pc+4;
	.imm20D(inst_data_in[31:20]),
	.imm_or_adr(out_mux7),
	.s_u_alu(ctrl2regE_sign_alu),
	.alu_ctrl(ctrl2regE_alu_ctrl),
	.be_memD(cnt2regE_be_mem),
	.we_memD(cntr2regE_we_mem),
	.we_regD(ctrl2regE_we_reg),
	.brch_typeD(ctrl2regE_brch_type),
	.mux9D(ctrl2regE_mux9),
	.mux8D(ctrl2regE_mux8),
	.mux8_2D(ctrl2regE_mux8_2),
	.mux8_3D(ctrl2regE_mux_3),
	.mux10D(ctrl2regE_mux10D),
	.clk(sys_clk),
	.enbD(hz2regE_enbE),
	.flasDE(hz2reg_flashE),
	.cmdD(ctrl2regE)
	.srcaD_out(regE2a_bpmux2),
	.srcbD_out(regE2a_bpmux4),
	.rs1D_out(regE2regM_rs1),
	.rs2D_out(regE2regM_rs2),
	.rdD_out(regE2regM_rd),
	.pcD_out(regE2a_sign_adder),//pc+4;
	.imm20D_out(regE2regM_imm20),
	.s_u_alu_out(regE2_sign_alu),
	.alu_ctrl_out(regE2_alu_ctrl),
	.be_memD_out(regE2regM_be_mem),
	.we_memD_out(regE2regM_we_mem),
	.we_regD_out(regE2regM_we_mem),
	.brch_typeD_out(regE2regM_brch_type),
	.mux9D_out(regE2regM_mux9),
	.mux8D_out(regE2_mux8),
	.mux8_2D_out(regE2_mux8_2),
	.mux8_3D_out(regE2_mux8_3),
	.mux10D_out(regE2regM_mux10),
	.cmdD_out(regE2regM_cmd),
	imm_or_adr_out(regE2b_sign_adder)
);
wire ctrl2hz;
wire[2:0] ctrl2regE_sx_ctrl;
cpu_ctrl(
	.fnct7(inst_data_in[31:30]),
	.fnct(inst_data_in[14:12]),
	.opcode(inst_data_in[6:0]),
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
	.mux4_2(ctrl2_mux4_2),
	.mux3(ctrl2_mux4_2),
	.mux1(ctrl2_mux1),
	.cmd(ctrl2regE_cmd),
	.rubish(ctrl2_rubish)
);
////end of decode phase

//// exeqution 
wire regE2_mux8;
wire regE2_mux8_2;
wire regE2_mux8_3;
wire[3:0] regE2_alu_ctrl;
wire regE2_alu_sign;
wire[31:0] regE2a_bpmux2;
wire[31:0] regE2b_bpmux4;
wire[31:0] regE2b_sign_adder;
wire[31:0] regEa_sign_adder;
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

assign out_mux8 = s_mux8 ? b_mux8 : a_mux8 // mux8
assign out_mux8_2 = s_mux8_2 ? b_mux8_2 : a_mux8_2 // mux8_2
assign out_mux8_3 = s_mux8_3 ? b_mux8_3 : a_mux8_3 // mux8_3

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

//// regE2regM
wire[1:0] regE2regM_be_mem;
wire regE2regM_we_mem;
wire regE2regM_mux10;
wire regE2regM_mux9;
wire[1:0] regE2regM_brch_type;
wire[1:0] regE2regM_cmd;
////
assign out_bpmux1 = s_bpmux1 ? b_bpmux1 : a_bpmux1 // bpmux1
assign out_bpmux2 = s_bpmux2 ? b_bpmux2 : a_bpmux2 // bpmux2
assign out_bpmux3 = s_bpmux3 ? b_bpmux3 : a_bpmux3 // bpmux3
assign out_bpmux4_2 = s_bpmux4_2 ? b_bpmux4_2 : a_bpmux4_2 // bpmux4

wire[31:0] alu2regM_result;
wire[1:0] alu2regM_cnd;
wire [19:0] regE2regM_imm20;
alu (
	.srca(out_mux8_2),
	.srcb(out_mux8_3),
	.cntl(regE2_alu_ctrl),
	.not_s(regE2_alu_sign),
	.result(alu2regM_result),
	.cnd(alu2regM_cnd)
);
wire[31:0] address;
assign a_bpmux1 = resultM;
assign b_bpmux1 = out_bpmux2;
assign a_bpmux2 = regE2a_bpmux2;
assign b_bpmux2 = wrt2reg_file;
assign b_bpmux4 = wrt2reg_file;
assign a_bpmux4 = regE2b_bpmux4;
assign a_bpmux3 = resultM;
assign b_bpmux3 = out_bpmux4;
assign a_mux8_2 = out_bpmux1;
assign b_mux8_2 = {regE2regM_imm20,{11{1'b0}}};
assign a_mux8 = out_bpmux3;
assign b_mux8 = regE2b_sign_adder;
assign a_mux8_3 = out_mux8;
assign b_nux8_3 = regE2b_sign_adder;

assign address = regE2a_sing_adder + regE2b_sign_adder;

reg_mem(
	.resultM(alu2_regM_resalt),
	.srcbM(regE2a_bpmux4),
	.cndM(regE2regM_cmd),
	.addrM(address),
	.rdM(regE2regM_rd),
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

	.resultM_out(regM2mem_result),
	.srcbM_out(regM2mem_srcb),
	.cndM_out(regM2brch_cnd_u),
	.addrM_out(regM2a_mux1),
	.rdM_out(regM2regW_rd),
	.be_memM_out(regM2regW_be_mem),
	.we_memM_out(regM2regW_we_mem),
	.we_regM_out(regM2regW_we_reg),
	.brch_typeM_out(regM2_cnd_u),
	.mux9M_out(regM2regW_mux9),
	.mux5M_out(regM2regW_mux5),
	.mux10M_out(regM2regW_mux10)
);

/// end muxs for exeqution stage 
/// end of execution





endmodule
