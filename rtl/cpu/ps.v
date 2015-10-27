module ps (
	input clk,
	input[31:0] adr_in,
	input[31:0] adr_out,
	input reset
);
reg[31:0] loc;
always@(posedge clk)
begin
	if(reset) begin
		loc <= 31'b0;	
	end
	else begin
		loc <= adr_in;
	end
end
assign adr_out = loc;

endmodule 
