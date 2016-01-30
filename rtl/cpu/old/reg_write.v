/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: reg_write.v
# Descriptions:
# 	register of write stage  
###########################################################
*/

module reg_write(
	input we_regW,
	input mux9W,
	input[31:0] resultW,
	input[4:0] rdW,
	input[31:0] memW,
	input clk,
	input flashW,
	input enbW,
	input[4:0] rs1W,
	input[4:0] rs2W,
	input[1:0] cmdW,
	input[19:0] imm20W,
	input[2:0] sx_2W_ctrl,
	input mux10W,
	
	output we_regW_out,
	output mux9W_out,
	output mux10W_out,
	output[31:0] resultW_out,
	output[4:0] rdW_out,
	output[31:0] memW_out,
	output[4:0] rs1W_out,
	output[4:0] rs2W_out,
	output[1:0] cmdW_out,
	output[19:0] imm20W_out,
	output[2:0] sx_2W_ctrl_out
);
reg we_regW_loc;
reg mux9W_loc;
reg[31:0] resultW_loc;
reg [4:0]rdW_loc;
reg[31:0] memW_loc;
reg [4:0] rs1W_loc;
reg [4:0] rs2W_loc;
reg[1:0] cmdW_loc;
reg[19:0] imm20W_loc;
reg[2:0] sx_2W_loc;
reg mux10_loc;
always @(posedge clk)
begin
	if(flashW)begin
		we_regW_loc <= 1'b0;
		mux9W_loc <= 1'b0;
		resultW_loc <= 32'b0;
		rdW_loc <= 5'b0;
		memW_loc <= 32'b0;
		rs1W_loc <= 5'b0;
		rs2W_loc <= 5'b0;
		cmdW_loc <=2'b0;
		imm20W_loc <=20'b0;
		sx_2W_loc <= 3'b0;
		mux10_loc <= 1'b0;
	end
	else begin
		if(enbW)begin
			we_regW_loc <= we_regW_loc;
			mux9W_loc <= mux9W_loc;
			resultW_loc <= resultW_loc;
			rdW_loc <= rdW_loc;
			memW_loc <= memW_loc;
			rs1W_loc <= rs1W_loc;
			rs2W_loc <= rs2W_loc;
			cmdW_loc <= cmdW_loc;
			imm20W_loc <= imm20W_loc;
			sx_2W_loc <= sx_2W_loc;
			mux10_loc <= mux10_loc;
		end
		else begin
			we_regW_loc <= we_regW;
			mux9W_loc <= mux9W;
			resultW_loc <= resultW;
			rdW_loc <= rdW;
			memW_loc <= memW;
			rs1W_loc <= rs1W;
			rs2W_loc <= rs2W;
			cmdW_loc <= cmdW;
			imm20W_loc <= imm20W;
			sx_2W_loc <= sx_2W_ctrl;
			mux10_loc <= mux10W;
		end
	end
end
assign rs1W_out = rs1W_loc;
assign rs2W_out = rs2W_loc;
assign we_regW_out = we_regW_loc;
assign mux9W_out = mux9W_loc;
assign mux10W_out = mux10_loc;
assign resultW_out = resultW_loc;
assign memW_out = memW_loc;
assign rdW_out = rdW_loc;
assign cmdW_out = cmdW_loc;
assign imm20W_out = imm20W_loc;
assign sx_2W_ctrl_out = sx_2W_loc;
endmodule
