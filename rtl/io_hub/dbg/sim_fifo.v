module sim_fifo();
	parameter DEPTH = 2;
	parameter SIZE	= 8;

	reg clk;
	
	reg wr_en;
	reg [SIZE-1:0] din;
	
	reg rd_en;
	wire [SIZE-1:0] dout;
	
	wire empty;
	wire full;

	fifo 
	#(
		.DEPTH(DEPTH),
		.SIZE(SIZE)
	) 
	fifo
	(
		.clk(clk),
		.wr_en(wr_en),
		.din(din),
		
		.rd_en(rd_en),
		.dout(dout),
		
		.empty(empty),
		.full(full)
	);
	
	initial begin
		clk = 1;
		forever
			#5 clk = ~clk;
	end
	
	initial begin
		wr_en = 1;
		rd_en = 0;
		
		din = 8'hAA;		
		#10 din = 8'hAB;
		#10 din = 8'hAC;
		#10 din = 8'hAD;
		#10 din = 8'hAE;
		
		#10 wr_en = 0;
		
		rd_en = 1;
		#40;
		
		wr_en = 1;		
		din = 8'hAA;
		rd_en = 0;		
		#10 din = 8'hAB;
			rd_en = 1;
		#10 wr_en = 0;
	end
endmodule
