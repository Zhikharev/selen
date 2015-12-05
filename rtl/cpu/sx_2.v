/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: sx_2.v
# Descriptions:
# 	controlleble sign extension for providing instruction working witn hot full word (2 bytes or 1 byte, half and byte responsible)
###########################################################
*/

module sx_2 (
	input[2:0] ctrl,
	input[31:0] data_in,
	output[31:0] data_out
);
reg[31:0] loc;
localparam BP =2'b00;
localparam LH =2'b01;
localparam LB =2'b10;


always @*
begin
	if(ctrl[2]) begin
		case(ctrl[1:0])
			BP: loc = data_in;
			LH: loc = {{16{data_in[15]}},data_in};//lw				
			LB: loc = {{24{data_in[7]}},data_in};//lh
			default: loc = loc;
		endcase
	end
	else begin
		case(ctrl[1:0])
			BP: loc = data_in;
			LH: loc = {{16{1'b0}},data_in};//lw				
			LB: loc = {{24{1'b0}},data_in};//lh
			default: loc = loc;
		endcase
			
	end
end 
assign data_out = loc;
endmodule
