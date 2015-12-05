/*
###########################################################
#
# Author: Bolotnokov Alexsandr 
#
# Project:SELEN
# Filename: brnch_cnd.v
# Descriptions:
# 	module is used for detection is branch taken or not 
###########################################################
*/

module brch_cnd(
		input[1:0] brnch_typeM,
		input[1:0] cndM,
		output mux1
);
localparam EQ = 2'b00;
localparam NE = 2'b01;
localparam LT = 2'b10;
localparam GE = 2'b11;

reg loc1;
always @*
begin
	case(brnch_typeM)
		EQ:begin
			if(cndM == 2'b11)begin
				loc1 = 1'b0;
			end
			else loc1 = 1'b1;
		end
		NE:begin
			if(cndM != 2'b11)begin
				loc1 = 1'b0;
			end
			else begin
				loc1 = 1'b1;
			end
		end
		LT:begin
			if(cndM == 2'b00)begin
				loc1 = 1'b0;
			end
			else begin
				loc1 = 1'b1;
			end
		end
		GE:begin
			if((cndM == 2'b10)||(cndM == 2'b11))begin
				loc1 = 1'b0;
			end
			else begin
				loc1 = 1'b1;
			end
		end
endcase
end
assign mux1 = loc1;

endmodule
