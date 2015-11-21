`timescale 1ns/ps

module test();

reg[31:0] data_in;
reg[31:0] adr_srca;
reg[31:0] adr_srsb;
reg[31:0] adr_wrt;
wire[31:0] out_srca;
wire[31:0] out_srcb;
reg clk,we,reset;
integer i;
initial begin
  	#3 
  	reset =1;
  	#3
  	reset =0;
	for(i=0;i<33;i=i+1) begin: forloop
		@(negedge clk);
		we =1;
		adr_wrt = i;
		data_in = i;
		@(posedge clk);
		we = 0;
		addr_srca = i;
		@(posedge clk)
		we = 1;
		addr_srcb = i;
	end	 
	#20;
	reset =1;
	#5
	reset =0;	
end
endmodule 
