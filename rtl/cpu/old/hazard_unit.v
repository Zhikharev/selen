33/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: cpu_top.v
# Descriptions:
# 	module solves hazard. Provides forwarding of data and stall and flash of stage registers 
###########################################################
*/

module hazard_unit(
	input reset,
	input clk,
	input[1:0] cmd_inD,
	input[1:0] cmd_inE,
	input[1:0] cmd_inM,
	input[1:0] cmd_inW,
	input[4:0] rs1E,
	input[4:0] rs2E,
	input[4:0] rs1M,
	input[4:0] rs2M,
	input[4:0] rs1W,
	input[4:0] rs2W,
	input[4:0] rdD,
	input[4:0] rdM,
	input[4:0] rdW,
	input[4:0] rdE,
	input[4:0] rs1D,
	input[4:0] rs2D,
	input we_regE,
	input we_regM,
	input we_regW,
	input mux1,//branch
	output bp1M,
	output bp2W,
	output bp3M,
	output bp4W,
	output bp5M,
	output mux2,
	
	output flashD,
	output flashE,
	output flashM,
	output flashW,
			
	output enbD,
	output enbE,
	output enbM,
	output enbW,

	output nop_gen_out,
	
	output val2il1,
	output val2dl1,
	input l1d_ack,
	input l1i_ack 
);
localparam lw_cmd = 2'b11;
localparam sw_cmd = 2'b10;
localparam jmp_cmd = 2'b01;
localparam other = 2'b00;
reg d_val;
//reg i_val;
reg hz2ctrl_loc;
reg mux2_loc;
reg flashD_loc;
reg flashE_loc;
reg flashM_loc;
reg flashW_loc;
reg enbD_loc;
reg enbE_loc;
reg enbM_loc;
reg enbW_loc;
reg nop_gen_loc;
reg state;
reg state_next;
reg[4:0] lw_rd;
localparam WHAIT = 1'b1;
localparam FREE = 1'b0;
/////////////// FSM for mem requests and answers 
always@(posedge clk) 
begin
	if(reset) begin
		state <= FREE;
		lw_rd <= 5'b0;
	end	
	else begin
		state <= state_next;
	end
end
always@* 
begin
	case(state)
		FREE:begin
			if(cmd_inM == lw_cmd)begin
				state_next = WHAIT;
				lw_rd = rdM;
			end
			else begin
				state_next = FREE;
			end
		end
		WHAIT:begin
			if(l1d_ack)begin
				state_next = FREE;
			end
		end
	endcase
end
//////////////////////
always@* begin
	if(reset)begin
		d_val = 1'b0;
	end	
	else begin	
		if(cmd_inM == lw_cmd || cmd_inM == sw_cmd)begin
			d_val = 1'b1;
		end
		else begin
			d_val = 1'b0;	
		end
	end
end
//////////////////////
always@* begin
	if(reset) begin
		hz2ctrl_loc = 1'b0;//check it 
		mux2_loc = 1'b1;
		flashD_loc = 1'b1;
		flashE_loc = 1'b1;
		flashM_loc = 1'b1;
		flashW_loc = 1'b1;
		enbD_loc = 1'b0;
		enbE_loc = 1'b0;
		enbM_loc = 1'b0;
		enbW_loc = 1'b0;
		nop_gen_loc = 1'b0;
	end
	else begin
		// every stage works 
		hz2ctrl_loc = 1'b0;//check it 
		mux2_loc = 1'b0;
		flashD_loc = 1'b0;
		flashE_loc = 1'b0;
		flashM_loc = 1'b0;
		flashW_loc = 1'b0;
		enbD_loc = 1'b0;
		enbE_loc = 1'b0;
		enbM_loc = 1'b0;
		enbW_loc = 1'b0;
		nop_gen_loc = 1'b0;
		// stalls
		if(~l1i_ack)begin
			mux2_loc = 1'b1;
			enbD_loc = 1'b1;
			enbE_loc = 1'b1;
			enbM_loc = 1'b1;
			enbW_loc = 1'b1;
		end
		//feture for speeding up allow to path out another command when lw and any anouther command has not the same rd 
		if((rdM == lw_rd)&&(rdM != 5'b0)&&(lw_rd != 5'b0)&&(state_next == WHAIT))begin
			mux2_loc = 1'b1;
			enbD_loc = 1'b1;
			enbE_loc = 1'b1;
			enbM_loc = 1'b1;
			enbW_loc = 1'b1;
		end
		//lw bubble 
		if((cmd_inE == lw_cmd)&&((rs1D == rdE)||(rs2D == rdE)&&(rs1D != 5'b0)))begin
			mux2_loc = 1'b1;
			enbD_loc = 1'b1;
			nop_gen_loc = 1'b1;
		end
		//branch misprediction penality
		if(~mux1)begin
			flashD_loc = 1'b1;
			flashE_loc = 1'b1;
			flashW_loc = 1'b1;
		end
		//for jmp hazard if wrt_end is 1 thefore nop gen = 1'b1 and enbD = 1'b1 core is waiting wrt_enb = 1'b0; also be aware of rd = zero in jump comands becous there is not need to write smt in registe file
		if(cmd_inD == jmp_cmd)begin
			if((we_regW == 1'b1)&&(rdW != 5'b0))begin
				mux2_loc = 1'b1;
				enbD_loc = 1'b1;
				nop_gen_loc = 1'b1;
			end
		end
	end
end

///// forwarding liters are here for mux are not for stages 
reg bp1M_loc;
reg bp2W_loc;
reg bp4W_loc;
reg bp3M_loc;
reg bp5M_loc;
always @*
begin
	if(reset)begin
		bp1M_loc = 1'b0;
		bp2W_loc = 1'b0;
		bp4W_loc = 1'b0;
		bp3M_loc = 1'b0;
		bp5M_loc = 1'b0;
	end
	else begin
		//forwarding form mem stage to exqution stage 
		if((rs1E != 5'b0)&&(rs1E == rdM)&&(we_regM == 1'b1))begin
			bp1M_loc = 1'b0;
		end
		else begin
			bp1M_loc = 1'b1;
		end

		if((rs2E != 5'b0)&&(rs2E == rdM)&&(we_regM == 1'b1))begin
			bp3M_loc = 1'b0;
		end
		else begin
			bp3M_loc = 1'b1;
		end
		//forwarding from writeback stage to exeqution stage 
		if((rs1E != 5'b0)&&(rs1E == rdW)&&(we_regW== 1'b1))begin
			bp2W_loc = 1'b1;
		end
		else begin
			bp2W_loc = 1'b0;
		end
		// forwarding from writeback stage to memory stage 
		if((rs2E != 5'b0)&&(rs2E == rdW)&&(we_regW== 1'b1))begin
			bp4W_loc = 1'b1;
		end
		else begin
			bp4W_loc = 1'b0;
		end
		if((cmd_inM == lw_cmd)&&(cmd_inW == lw_cmd)&&((rdW == rs1W)||(rdW == rs2W)))begin
			bp5M_loc = 1'b1;
		end
		else begin
			bp5M_loc = 1'b0;
		end
	end
end
assign bp1M = bp1M_loc;
assign bp3M= bp3M_loc;
assign bp2W = bp2W_loc;
assign bp4W = bp4W_loc;
assign bp5M = bp5M_loc;
assign flashD = flashD_loc;
assign flashE = flashE_loc;
assign flashM = flashM_loc;
assign flashW = flashW_loc;
assign mux2 = mux2_loc;
assign enbD = enbD_loc;
assign enbE = enbE_loc;
assign enbM = enbM_loc;
assign enbW = enbW_loc;
assign hz2ctrl = hz2ctrl_loc;/// be aware 
assign nop_gen_out = nop_gen_loc;
assign vla2il1 = mux2_loc;
assign val2dl1 = d_val;
endmodule

