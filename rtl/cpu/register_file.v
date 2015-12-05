/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: reg_file.v
# Descriptions:
# 	register files include 1 write potr and 2 port for reading 
	amount of register cells is 32
	bitwise of register's cell 4 bytes 
###########################################################
*/

module reg_file (
	input clk,
	input reset,
	input we,//1 writting is allowed
	input[31:0]data_in,
	input[4:0] adr_wrt,
	input[4:0] adr_srca,
	input[4:0] adr_srcb,
	//input [1:0] reg_be,
	output[31:0] out_srca,
	output[31:0] out_srcb,
	output done
);
integer i;
reg [31:0] loc_regs [0:31];
reg[31:0] loc_srca, loc_srcb;
reg done_loc;
always@(posedge clk)
begin
	if(reset) begin
		for(i = 0; i<32; i=i+1)begin
	 		loc_regs[i] <=0;
	 		done_loc <= 1'b0;
		end
	end
	else begin
		if(we)begin
			if(adr_wrt != 0) begin 
				loc_regs[adr_wrt] <= data_in;
				done_loc <= 1'b1;
			end
			else begin 
				done_loc <=1'b0;
				loc_regs[5'b0] <= 31'b0;
			end
		end
	end
end

always @(negedge clk)
begin
	if(reset) begin
		
	end
	else begin
		done_loc <=1'b0;
		loc_srca <= loc_regs[adr_srca];
		loc_srcb <= loc_regs[adr_srcb];
	end

end
assign done = done_loc;
assign out_srca = loc_srca;
assign out_srcb = loc_srcb;
endmodule

