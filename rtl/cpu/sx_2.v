module sx_2 (
	input[1:0] cntr,
	input[31:0] data_in,
	input s_u,///1 respect to sign operations
	output[31:0] data_out
);
reg[31:0] loc;
always @*
begin
	if(s_u) begin
		case(cntr)
			2'b00: loc = data_in;
			2'b01: loc = {{16{data_in[15]}},data_in};//lw				
			2'b10: loc = {{24{data_in[7]}},data_in};//lh
			2'b11: loc = 31'bz;
		endcase
	end
	else  begin
		case(cntr)
			2'b00: loc = data_in;
			2'b01: loc = {{16{1'b0}},data_in};//lw				
			2'b10: loc = {{24{1'b0}},data_in};//lh
			2'b11: loc = 31'bz;
		endcase
			
	end
end 
assign data_out = loc;
endmodule
