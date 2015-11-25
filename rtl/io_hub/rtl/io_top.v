module io_top(
		input clk,
		input rst,
		
		//UART
		input rx,
		
		//IO inteface data
		input  				io_stb_i,
		output 	 			io_ack_o,
		input         		io_we_i,
		input 	[15:0] 		io_addr_i,
		output 	[31:0] 		io_data_o,
		
		// DMA
		input 				dma_cyc_i,
		output 				dma_stb_o,
		input				dma_ack_i, 
		output 				dma_we_o,
		output	[15:0] 		dma_addr_o,
		output 	[31:0]		dma_data_o
);

endmodule
