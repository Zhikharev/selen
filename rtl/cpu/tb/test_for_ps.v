`timescale 1ns/1ps

module test_ps;

	reg clk;
	reg[31:0] adr_in;
	reg reset;
	wire[31:0] adr_out;

always begin
	clk =0;
	#5
	clk = ~clk;
end 

initial begin
	#20	
	reset = 1;
	#5
	reset = 0;
	#1
	adr_in = 31'b01010;
	#2
	adr_in = 31'b00001;
	#2
	adr_in = 31'b111111111111;

end

endmodule
