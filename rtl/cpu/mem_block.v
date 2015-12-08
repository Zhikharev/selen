/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: mem_block.v
# Descriptions:
# 	block provide interaction betwine cpu amd memory   
###########################################################
*/

module mem_block(
	input rst,
	input clk,
	
	input mux1,
	input mux2,
	input mux3,
	input mux4,
	input mux4_2,
	input stall,
	
	input ack_in,
	input[31:0] inst_in,
	output[31:0] inst_out,
	input[31:0] imm_20,
	input [31:0] imm_12,
	input [31:0] reg_in,
	input[31:0] brch_address,

	output[31:0] inst_addr,
	output[31:0]pc_next_out,
	output cyc,
	output stb
);
reg[31:0] pc;
wire[31:0] pc_next;
//wire[31:0] a_mux3;
//wire[31:0] b_mux3;
wire[31:0] out_mux3;
//wire[31:0] a_mux1;
//wire[31:0] b_mux1;
wire[31:0] out_mux1;
//wire[31:0] a_mux4;
//wire[31:0] b_mux4;
wire[31:0] out_mux4;
//wire[31:0] a_mux4_2;
//wire[31:0] b_mux4_2;
wire[31:0] out_mux4_2;

wire [31:0] adder;
always@(posedge clk)
begin
	if(rst)begin
		pc <= 31'b0;
	end
	else begin
		pc <= pc_next;
	end
end
//mem FSM
reg cyc_loc;
reg stb_loc; 
reg[1:0] state;
reg[1:0] state_next;
always@(posedge clk)begin
	if((rst)||(stall))begin
		state <= 2'b0;
	end	
	else begin
		state <= state_next;
	end
end
always@* begin
	case(state)
		2'b00:begin
			state_next = 2'b01;
			stb_loc = 1'b0;
			cyc_loc =1'b0;
		end
		2'b01:begin
			state_next = 2'b10;
			stb_loc = 1'b1;
			cyc_loc = 1'b1;
		end
		2'b10:begin
			if(ack_in) begin
				state_next = 2'b11;
				stb_loc = 1'b0;
				cyc_loc = 1'b1;
			end
			else begin
				state_next = 2'b11;
			end
		end
		2'b11:begin
			state_next = 2'b01;
			stb_loc = 1'b0;
			cyc_loc = 1'b1;
		end
	endcase;
end
//assign cyc = ((stall)||(~ack_in))? 1'b0:1'b1;
//assign stb = ((stall)||(~ack_in))? 1'b0:1'b1;
assign cyc = cyc_loc;
assign stb = stb_loc;
assign out_mux4_2 = (mux4_2)? pc : reg_in;
assign out_mux4 = (mux4)? 31'b100 : imm_12;
assign pc_next = (mux2)? pc : out_mux3;//mux2
assign out_mux3 = (mux3)? imm_20 : out_mux1;
assign out_mux1 = (mux1) ? adder : brch_address;
assign adder = out_mux4 + out_mux4_2;
assign pc_next_out = pc_next + 4;
assign inst_addr = pc;
 
endmodule
