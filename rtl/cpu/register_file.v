module reg_file (
	input clk,
	input reset,
	input we,//1 writting is allowed
	input[31:0]data_in,
	input[4:0] adr_wrt,
	input[4:0] adr_srca,
	input[4:0] adr_srcb,
	output[31:0] out_srca,
	output[31:0] out_srcb 
);
integer i;
reg [4:0] loc_regs [31:0];
reg[31:0] loc_srca, loc_srcb;	
always@(posedge clk)
begin
	if(reset) begin
		for(i = 0; i<32; i=i+1)begin
	 	      loc_regs[i] <=0;
		end
	end
	else begin
		if(we)begin
			loc_regs[adr_wrt] <= data_in;			
		end
	end
end

always @(negedge clk)
begin
	if(reset) begin
		
	end
	else begin
		loc_srca <= loc_regs[adr_srca];
		loc_srcb <= loc_regs[adr_srcb];	
	end

end
always @*
begin
	loc_regs[5'b0] <= 31'b0;
end	
assign out_srca = loc_srca;
assign out_srcb = loc_srcb;

endmodule

