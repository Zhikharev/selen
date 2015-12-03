module mem_ctr(
	input akn_in,
	output cyc_out,
	output stb_out,
	input full,
	input empty,
	output rd_enb,
	output wrt_enb,
	input rst,
	input clk,
	input stall_in
);
localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;
localparam S3 = 2'b11;
reg [1:0]state_next;
reg [1:0]state;
reg stb_loc;
reg akn_loc;
reg cyc_loc;
reg wrt_enb_loc;
reg rd_enb_loc;
always@(posedge clk)
begin
	if(rst)begin
		state <= S0;
		wrt_enb_loc <= 1'b0;
		rd_enb_loc <= 1'b0;
	end
	else begin
		if((stall_in)&&(~akn_in))begin
			state <= state;
		end
		else begin
			state <= state_next;
		end
	end
	
end
always@*
begin
	case(state)
		S0:begin
			state_next = S1;
		end
		S1:begin
			if(~full)begin
				wrt_enb_loc = 1'b1;
				state_next = S1;
			end
			else begin
				wrt_enb_loc = 1'b0;
				state_next = S2;
			end
		end
		S2:begin
			if(empty)begin
				state_next = S1;
				rd_enb_loc = 1'b0;
			end
			else begin
				state_next = S2;
				rd_enb_loc = 1'b1;
			end
		end
	endcase;
end
always@*
begin
	case(state)
		S0:begin
			stb_loc = 1'b0;
			cyc_loc = 1'b0;
		end
		S1:begin
			stb_loc = 1'b0;
			cyc_loc = 1'b0;
		end
		S2:begin
			stb_loc = 1'b1;
			cyc_loc = 1'b1;
		end
	endcase;
end
assign stb_out = stb_loc;
assign cyc_out = cyc_loc;
assign wrt_enb = wrt_enb_loc;
assign rd_enb = rd_enb_loc;
endmodule
