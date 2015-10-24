module test_alu();

reg[31:0] srca,srcb;
reg[3:0] cntr;
reg[4:0] shamt;
reg not_s;
wire[31:0] resaltl;
wire[1:0] cnd;

localparam ADD = 4'b0000;
localparam AND = 4'b0001;
localparam OR  = 4'b0010;
localparam XOR = 4'b0011;
localparam SLL = 4'b0100;
localparam SRL = 4'b0101;
localparam SUB = 4'b0110;
localparam SRA = 4'b0111;
localparam AM  = 4'b1000;



 alu uut(
	.srca(srca),
	.srcb(srcb),
	.shamt(shamt),	
	.cntr(cntr),
	.not_s(not_s),
	.resalt(resalt),
	.cnd(cnd)
);
initial begin
	#5
	not_s = 1;
	#1
	srca = 10'd5;
	#1	
	srca = 10'd5;
	#1
	cntr = ADD;
	//$display('%d = %d + %d',resalt,srca,srcb);	
	#5
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = ADD;
	#5
	//$display('%d = %d + %d',resalt,srca,srcb);	
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = AND;
	//$display('%d = %d & %d',resalt,srca,srcb);
	#5
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = OR;
	#5
	//$display('%d = %d | %d',resalt,srca,srcb);	
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = XOR;
	#5
	//$display('%d = %d ^ %d',resalt,srca,srcb);		
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = SLL;
	#5	
	//$display('%d = shift lift %d',resalt, srcb[4:0]);		
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = SRL;
	#5
	//$display('%d = shift right %d',resalt, srcb[4:0]);	
	#1
	srca = 10'd1;
	#1	
	srca = 10'd5;
	#1
	cntr = SUB;
	#5
	//$display('%d = %d - %d',resalt,srca,srcb);	
	#1
	srca = 10'd3;
	#1	
	srca = 10'd5;
	#1
	cntr = SRA;
	#5
	//$display('%d = arifmetic shift right %d',resalt, srcb[4:0]);	
		
	#1
	srca = 10'd3;
	#1	
	srca = 10'd5;
	#1
	cntr = AM;
	#5
	//$display('%d = AM',resalt);	
	#1
	srca = 10'd2;
	#1	
	srca = 10'd5;
	#1
	cntr = AM;
	//$display('%d = AM',resalt);
	
////////////	
	
	#15
	not_s = 1;
	#1
	srca = 10'd5;
	#1	
	srca = 10'd5;
	#1
	cntr = ADD;
	//$display('%d = %d + %d',resalt,srca,srcb);	
	#5
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = ADD;
	#5
	//$display('%d = %d + %d',resalt,srca,srcb);	
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = AND;
	//$display('%d = %d & %d',resalt,srca,srcb);
	#5
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = OR;
	#5
	//$display('%d = %d | %d',resalt,srca,srcb);	
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = XOR;
	#5
	//$display('%d = %d ^ %d',resalt,srca,srcb);		
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = SLL;
	#5	
	//$display('%d = shift lift %d',resalt, srcb[4:0]);		
	#1
	srca = -5;
	#1	
	srca = 10'd5;
	#1
	cntr = SRL;
	#5
	//$display('%d = shift right %d',resalt, srcb[4:0]);	
	#1
	srca = 10'd1;
	#1	
	srca = 10'd5;
	#1
	cntr = SUB;
	#5
	//$display('%d = %d - %d',resalt,srca,srcb);	
	#1
	srca = 10'd3;
	#1	
	srca = 10'd5;
	#1
	cntr = SRA;
	#5
	//$display('%d = arifmetic shift right %d',resalt, srcb[4:0]);	
		
	#1
	srca = 10'd3;
	#1	
	srca = 10'd5;
	#1
	cntr = AM;
	#5
	//$display('%d = AM',resalt);	
	#1
	srca = 10'd2;
	#1	
	srca = 10'd5;
	#1
	cntr = AM;
	//$display('%d = AM',resalt);
	
end

endmodule
