module alu (
	input[31:0]srca,// upper 
	input[31:0]srcb,// lower
	input[3:0] cntl,
	input not_s, // if 1 sign is	
	output[31:0] resalt,
	output[1:0] cnd//conditional
);

localparam ADD = 4'b0000;
localparam SLT = 4'b0001;
localparam AND  = 4'b0010;
localparam XOR = 4'b0011;
localparam OR = 4'b0100;
localparam XOR = 4'b0101;
localparam SLL = 4'b0110;
localparam SRL = 4'b0111;
localparam SUB  = 4'b1000;
localparam SRA = 4'b1001;
localparam AM = 4'b1010;
reg[31:0]loc_resalt;
wire[31:0]loc_srca;
wire[31:0]loc_srcb;
wire[1:0] loc_cnd;

always@*
begin
	case(cntl)
		ADD: loc_resalt = loc_srca + loc_srcb;
		AND: loc_resalt = loc_srca & loc_srcb;
		OR:  loc_resalt = loc_srca | loc_srcb;
		XOR: loc_resalt = loc_srca ^ loc_srcb;
		SLL: loc_resalt = loc_srca >> loc_srcb[4:0];
		SRL: loc_resalt = loc_srca << loc_srcb[4:0];
		SUB: loc_resalt = loc_srca - loc_srcb;
		SRA: loc_resalt = loc_srca >>> loc_srcb[4:0];
		AM:  loc_resalt = (loc_srca + loc_srcb) >> 2;
		SRL: loc_resalt = 
			if(loc_srca < loc_srcb) loc_resalt = 1'b1;
			else loc_resalt = 1'b0;
		end
		SLTU: begin
			if((loc_srca < loc_srcb)&&(loc_srcb != 31'b0)) loc_resalt = 1'b1;
			else loc_resalt = 1'b0
		end
		endcase
	
end

assign loc_srca = not_s ? srca : {1'b0,srca[30:0]};
assign loc_srcb = not_s ? srcb : {1'b0,srcb[31:0]};
assign resalt = loc_resalt;
assign cnd[0] = loc_resalt[31]; // for branches but it might be useless becose I'd like use branch predicter
assign cnd[1] = (loc_resalt == 31'b0) ? 1'b1 : 1'b0;  


endmodule 
