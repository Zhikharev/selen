module sx_2 (
	input[1:0] cntr,
	input[31:0] data_in,
	input s_u,///1 respect to sign operations
	output[31:0] data_out
);
reg[31:0] loc;
localparam BP =2'b00;
localparam LH =2'b01;
localparam LB =2'b10;


always @*
begin
	if(s_u) begin
		case(cntr)
			BP: loc = data_in;
			LH: loc = {{16{data_in[15]}},data_in};//lw				
			LB: loc = {{24{data_in[7]}},data_in};//lh
			default: loc = loc;
		endcase
	end
	else  begin
		case(cntr)
			BP: loc = data_in;
			LH: loc = {{16{1'b0}},data_in};//lw				
			LB: loc = {{24{1'b0}},data_in};//lh
			default: loc = loc;
		endcase
			
	end
end 
assign data_out = loc;
endmodule
