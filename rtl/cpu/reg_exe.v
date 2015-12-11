/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: reg_exe.v
# Descriptions:
# 	register of execution stage  
###########################################################
*/

module reg_exe(
	input[31:0] srcaE,
	input [31:0] srcbE,
	input [4:0] rs1E,
	input [4:0] rs2E,
	input [4:0] rdE,
	input[31:0] pcE,//pc+4;
	input [19:0] imm20E,
	input [31:0] imm_or_addr,
	input s_u_alu,
	input[3:0] alu_ctrl,
	input[1:0] be_memE,
	input we_memE,
	input we_regE,
	input[1:0] brch_typeE,
	input mux9E,
	input mux8E,
	input mux8_2E,
	input mux8_3E,
	input mux10E,
	input clk,
	input enbE,
	input flashE,
	input[1:0] cmdE,
	input[2:0] sx_2E_ctrl,

	input nop_gen,

	output[31:0] srcaE_out,
	output [31:0] srcbE_out,
	output [4:0] rs1E_out,
	output [4:0] rs2E_out,
	output [4:0] rdE_out,
	output [31:0]pcE_out,//pc+4;
	output [19:0] imm20E_out,
	output s_u_alu_out,
	output[3:0] alu_ctrl_out,
	output[1:0] be_memE_out,
	output we_memE_out,
	output we_regE_out,
	output[1:0] brch_typeE_out,
	output mux9E_out,
	output mux8E_out,
	output mux8_2E_out,
	output mux8_3E_out,
	output mux10E_out,
	output[31:0] imm_or_addr_out,
	output[1:0] cmdE_out,
	output[2:0] sx_2E_ctrl_out
);
reg [31:0] srcaE_loc;
reg [31:0] srcbE_loc;
reg [4:0] rs1E_loc;
reg [4:0] rs2E_loc;
reg [4:0] rdE_loc;
reg [31:0] pcE_loc;//pc+4_loc;
reg [19:0] imm20E_loc;
reg s_u_alu_loc;
reg [3:0] alu_ctrl_loc;
reg[1:0] be_memE_loc;
reg we_memE_loc;
reg we_regE_loc;
reg[1:0] brch_typeE_loc;
reg mux9E_loc;
reg mux8E_loc;
reg mux8_2E_loc;
reg mux8_3E_loc;
reg mux5E_loc;
reg mux10E_loc;
reg[2:0] sx_2E_loc;
reg [1:0] cmdE_loc;
reg[31:0] imm_or_addr_loc;
always @(posedge clk)
begin
	if(flashE) begin
		srcaE_loc <= 32'b0;
		srcbE_loc <= 32'b0;
		rs1E_loc <= 5'b0;
		rs2E_loc <= 5'b0;
		rdE_loc <= 5'b0;
		pcE_loc <= 32'b0;
		imm20E_loc <= 32'b0;
		s_u_alu_loc <= 1'b0;
		alu_ctrl_loc <= 4'b0;
		be_memE_loc <= 1'b0;
		we_memE_loc <= 1'b0;
		we_regE_loc <= 1'b0;
		brch_typeE_loc <= 1'b0;
		mux9E_loc <= 1'b0;
		mux8E_loc <= 1'b0;
		mux8_2E_loc <= 1'b0;
		mux8_3E_loc = 1'b0;
		mux10E_loc <= 1'b0;
		cmdE_loc[1:0] <= 2'b00;
		imm_or_addr_loc <= 31'b0;
		sx_2E_loc <= 3'b0;
	end
	else begin
		if(enbE)begin
			srcaE_loc <= srcaE_loc;
			srcbE_loc <= srcbE_loc;
			rs1E_loc <= rs1E_loc;
			rs2E_loc <= rs2E_loc;
			rdE_loc <= rdE_loc;
			pcE_loc <= pcE_loc;
			imm20E_loc <= imm20E_loc;
			s_u_alu_loc <= s_u_alu_loc;
			alu_ctrl_loc <= alu_ctrl_loc;
			be_memE_loc <= be_memE_loc;
			we_memE_loc <= we_memE_loc;
			we_regE_loc <= we_regE_loc;
			brch_typeE_loc <= brch_typeE_loc;
			mux9E_loc <= mux9E_loc;
			mux8E_loc <= mux8E_loc;
			mux8_2E_loc <= mux8_2E_loc;
			mux8_3E_loc <= mux8_3E_loc;
			mux10E_loc <= mux10E_loc;
			cmdE_loc <= cmdE_loc;
			imm_or_addr_loc <= imm_or_addr_loc;
			sx_2E_loc <= sx_2E_loc;
		end
		else begin
			srcaE_loc <= srcaE;
			srcbE_loc <= srcbE;
			rs1E_loc <= rs1E;
			rs2E_loc <= rs2E;
			rdE_loc <= rdE;
			pcE_loc <= pcE;
			imm20E_loc <= imm20E;
			s_u_alu_loc <= s_u_alu;
			alu_ctrl_loc <= alu_ctrl;
			be_memE_loc <= be_memE;
			we_memE_loc <= we_memE;
			we_regE_loc <= we_regE;
			brch_typeE_loc <= brch_typeE;
			mux9E_loc <= mux9E;
			mux8E_loc <= mux8E;
			mux8_2E_loc <= mux8_2E;
			mux8_3E_loc <= mux8_3E;
			mux10E_loc <= mux10E;
			cmdE_loc <= cmdE;
			imm_or_addr_loc <= imm_or_addr;
			sx_2E_loc <= sx_2E_ctrl;
		end
	end
end

assign srcaE_out = (nop_gen)?31'b0:srcaE_loc;
assign srcbE_out = (nop_gen)?31'b0:srcbE_loc;
assign rs1E_out = rs1E_loc;
assign rs2E_out = rs2E_loc;
assign rdE_out = rdE_loc;
assign pcE_out = pcE_loc;
assign imm20E_out = (nop_gen)?321'b0:imm20E_loc;
assign s_u_alu_out = s_u_alu_loc;
assign alu_ctrl_out = alu_ctrl_loc;
assign be_memE_out = (nop_gen)?1'b0:be_memE_loc;
assign we_memE_out = (nop_gen)?1'b0:we_memE_loc;
assign we_regE_out = (nop_gen)?1'b0:we_regE_loc;
assign brch_typeE_out = brch_typeE_loc;
assign mux9E_out = mux9E_loc;
assign mux8E_out = mux8E_loc;
assign mux8_2E_out = mux8_2E_loc;
assign mux8_3E_out = mux8_3E_loc;
assign mux10E_out = (nop_gen)?1'b0:mux10E_loc;
assign cmdE_out = cmdE_loc;
assign imm_or_addr_out = imm_or_addr_loc;
assign sx_2E_ctrl_out = sx_2E_loc;
endmodule
