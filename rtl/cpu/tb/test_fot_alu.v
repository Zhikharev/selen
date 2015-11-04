`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:39:42 10/29/2015
// Design Name:   alu
// Module Name:   E:/ISE/CPU/CPU/alu_test.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_test;

	// Inputs
	reg [31:0] srca;
	reg [31:0] srcb;
	reg [3:0] cntl;
	reg not_s;

	// Outputs
	wire [31:0] resalt;
	wire [1:0] cnd;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.srca(srca), 
		.srcb(srcb), 
		.cntl(cntl), 
		.not_s(not_s), 
		.resalt(resalt), 
		.cnd(cnd)
	);
localparam ADD = 4'b0000;
localparam SLT = 4'b0001;
localparam SLTU = 4'b0010;
localparam AND  = 4'b0011;
localparam OR = 4'b0100;
localparam XOR = 4'b0101;
localparam SLL = 4'b0110;
localparam SRL = 4'b0111;
localparam SUB  = 4'b1000;
localparam SRA = 4'b1001;
localparam AM = 4'b1010;
	
	initial begin
		#10
		not_s = 1'b1;
		#2
		srca = 31'b1010;
		srcb = 31'b01;
		#3
		cntl = ADD;
		#3
		cntl = SLT;
		#3
		cntl = AND;
		#3
		cntl = OR;
		#3
		cntl = XOR;
		#3
		cntl = SLL;
		#3
		cntl = SRL;
		#3
		cntl = SUB;
		#3
		cntl = SRA;
		#3
		cntl = AM;

		#10

		#10
		not_s = 1'b1;
		#2
		srca = 31'hfffa;
		srcb = 31'hfff1;
		#3
		cntl = ADD;
		#3
		cntl = SLT;
		#3
		cntl = AND;
		#3
		cntl = OR;
		#3
		cntl = XOR;
		#3
		cntl = SLL;
		#3
		cntl = SRL;
		#3
		cntl = SUB;
		#3
		cntl = SRA;
		#3
		cntl = AM;
		
		
		
		
		
		
		
		
		
	end
      
endmodule


