module hazard_unit(
	input reset,
	input brnch,
	input lw,////from cntr nit
	input[4:0] rs1E,
	input[4:0] rs2E,
	input[4:0] rdM,
	input[4:0] rdW,
	input we_regM,
	input we_regW,
	
	output bp1M,
	output bp2W,
	output bp3M,
	output bp4W,
	output mux2,
	
	output flashD,
	output flashE,
	output flashM,
	output flashW,

	output enbD,
	output endE,
	output enbM,
	output enbW
);
reg mux2_loc;
reg flashD_loc;
reg flashE_loc;
reg flashM_loc;
reg flashW_loc;
reg enbD_loc;
reg enbE_loc;
reg enbM_loc;
reg enbW_loc;
always @*
begin
	if(reset)begin
		flashD_loc = 1'b1;
		flashE_loc = 1'b1;
		flashM_loc = 1'b1;
		flashW_loc = 1'b1;
	end
	else begin
		enbE_loc = 1'b0;
		enbM_loc = 1'b0;
		enbW_loc = 1'b0;
		if(brnch)begin
			enbD_loc = 1'b1;
			enbE_loc = 1'b1;
		end
		if(lw)begin
			enbD_loc = 1'b1;
			mux2_loc = 1'b1;
		end
	end
end
///// forwarding liters are here for mux are not for stages 
reg bp1M_loc;
reg bp2W_loc;
reg bp4W_loc;
reg bp3M_loc;

always @*
begin
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

	if((rs1E != 5'b0)&&(rs1E == rdW)&&(we_regW== 1'b1))begin
		bp2W_loc = 1'b1;
	end
	else begin
		bp2W_loc = 1'b0;
	end

	if((rs2E != 5'b0)&&(rs2E == rdW)&&(we_regW== 1'b1))begin
		bp4W_loc = 1'b1;
	end
	else begin
		bp4W_loc = 1'b0;
	end
end

assign bp1M = bp1M_loc;
assign bp3M= bp3M_loc;
assign bp2W = bp2W_loc;
assign bp4W = bp4W_loc;
assign flashD = flashD_loc;
assign flashE = flashE_loc;
assign flashM = flashM_loc;
assign flashW = flashW_loc;
assign mux2 = mux2_loc;
assign enbD = enbD_loc;
assign enbE = enbE_loc;
assign enbM = enbM_loc;
assign enbW = enbW_loc;
endmodule 
