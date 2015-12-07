/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: reg_mem.v
# Descriptions:
# 	register of memory stage  
###########################################################
*/

module reg_mem(
	input [31:0] resultM,
	input[31:0] srcbM,
	input[1:0] cndM,
	input[31:0] addrM,
	input[4:0] rdM,
	input[1:0] be_memM,
	input we_memM,
	//input be_regM,
	input we_regM,
	input[1:0] brch_typeM,
	input mux9M,
	input mux10M,
	input clk,
	input enbM,
	input flashM,
	input[4:0] rs1M,
	input[4:0] rs2M,
	input[1:0] cmdM,
	input[19:0] imm20M,
	input[2:0] sx_2M_ctrl,

	output[31:0] resultM_out,
	output[31:0] srcbM_out,
	output[1:0] cndM_out,
	output[31:0] addrM_out,
	output[4:0] rdM_out,
	output[1:0] be_memM_out,
	output we_memM_out,
	//output be_regM_out,
	output we_regM_out,
	output[1:0] brch_typeM_out,
	output mux9M_out,
	output mux10M_out,
	output[4:0] rs1M_out,
	output[1:0] cmdM_out,
	output[4:0] rs2M_out,
	output[19:0] imm20M_out,
	output[2:0] sx_2M_ctrl_out
);
reg [31:0] resultM_loc;
reg [31:0] srcbM_loc;
reg[1:0] cndM_loc;
reg[31:0] addrM_loc;
reg[4:0] rdM_loc;
reg[1:0] be_memM_loc;
reg we_memM_loc;
reg we_regM_loc;
reg[1:0] brch_typeM_loc;
reg mux9M_loc;
reg rsM_loc;
reg mux10M_loc;
reg[1:0] cmdM_loc;
reg[4:0] rs1M_loc;
reg[4:0] rs2M_loc;
reg[19:0] imm20M_loc;
reg[2:0] sx_2M_loc;
always @(posedge clk)
begin
	if(flashM) begin
		resultM_loc <= 32'b0;
		srcbM_loc <= 32'b0;
		cndM_loc <= 2'b0;
		addrM_loc <= 32'b0;
		rdM_loc <= 1'b0;
		be_memM_loc <= 1'b0;
		we_memM_loc <= 1'b0;
		we_regM_loc <= 1'b0;
		brch_typeM_loc <= 1'b0;
		mux9M_loc <= 1'b0;
		rdM_loc <= 5'b0;
		mux10M_loc <= 1'b0;
		rs1M_loc <= 5'b0;
		rs2M_loc <= 5'b0;
		imm20M_loc <= 20'b0;
		cmdM_loc <= 2'b0;
		sx_2M_loc <= 3'b0;
		
	end
	else begin
		if(enbM)begin
			resultM_loc <= resultM_loc;
			srcbM_loc <= srcbM_loc;
			cndM_loc <= cndM_loc;
			addrM_loc <= addrM_loc;
			rdM_loc <= rdM_loc;
			be_memM_loc <= be_memM_loc;
			we_memM_loc <= we_memM_loc;
			we_regM_loc <= we_regM_loc;
			brch_typeM_loc <= brch_typeM_loc;
			mux9M_loc <= mux9M_loc;
			mux10M_loc <= mux10M_loc;
			rdM_loc <= rdM_loc;
			rs1M_loc <= rs1M_loc;
			rs2M_loc <= rs2M_loc;
			imm20M_loc <= imm20M_loc;
			cmdM_loc <= cmdM;
			sx_2M_loc <= sx_2M_loc;
		end
		else begin
			resultM_loc <= resultM;
			cndM_loc <= cndM;
			srcbM_loc <= srcbM;
			addrM_loc <= addrM;
			rdM_loc <= rdM;
			be_memM_loc <= be_memM;
			we_memM_loc <= we_memM;
			we_regM_loc <= we_regM;
			brch_typeM_loc <= brch_typeM;
			mux9M_loc <= mux9M;
			mux10M_loc <= mux10M;
			rdM_loc <= rdM;
			rs1M_loc <= rs1M;
			rs2M_loc <= rs2M;
			imm20M_loc <= imm20M;
			cmdM_loc <= cmdM;
			sx_2M_loc <= sx_2M_ctrl;
		end
	end
end
assign rs1M_out = rs1M_loc;
assign rs2M_out = rs2M_loc;
assign resultM_out = resultM_loc;
assign srcbM_out = srcbM_loc;
assign cndM_out = cndM_loc;
assign addrM_out = addrM_loc;
assign be_memM_out = be_memM_loc;
assign we_memM_out = we_memM_loc;
assign we_regM_out = we_regM_loc;
assign brch_typeM_out = brch_typeM_loc;
assign mux9M_out = mux9M_loc;
assign mux10M_out = mux10M_loc;
assign rsM_out = rsM_loc;
assign imm20M_out = imm20M_loc;
assign cmdM_out = cmdM_loc;
assign sx_2M_ctrl_out = sx_2M_loc;
assign rdM_out = rdM_loc;
endmodule
