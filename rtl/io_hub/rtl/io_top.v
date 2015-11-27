module io_top(
		input clk,
		input rst,
		
		//UART
		input rx,
		input tx,
		
		//IO inteface data
		input  				io_stb_i,
		output 	 			io_ack_o,
		input         		io_we_i,
		input 	[15:0] 		io_addr_i,
		output 	[31:0] 		io_data_o,
		output 	[31:0] 		io_data_i,
		
		// DMA
		input 				dma_cyc_i,
		output 				dma_stb_o,
		input				dma_ack_i, 
		output 				dma_we_o,
		output	[15:0] 		dma_addr_o,
		output 	[31:0]		dma_data_o
);

	wire [31:0] dout;
	wire data_ready;

	wire [31:0] data;
	wire [31:0] status_reg;
	wire [31:0] addr_first_reg;
	wire [31:0] addr_end_reg;
	
	decode decode(
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.dout(dout),
		.data_ready(data_ready)
	);
		
	state_mashine state_mashine(
		.clk(clk),
		.rst(rst),
		.dready(data_ready),
		.din(dout),
		.data(data),
		.status_reg(status_reg),
		.addr_first_reg(addr_first_reg),
		.addr_end_reg(addr_end_reg)
	);
	
	io_hub io_hub(
		.clk(clk),
		.rst(rst),
		.data(data),
		.status_reg(status_reg),
		.addr_first_reg(addr_first_reg),
		.addr_end_reg(addr_end_reg),

		// IO inteface data
		.io_stb_i(io_stb_i),
		.io_ack_o(io_ack_o),
		.io_we_i(io_we_i),
		.io_addr_i(io_addr_i),
		.io_data_o(io_data_o),

		// DMA
		.dma_cyc_i(dma_cyc_i),
		.dma_stb_o(dma_stb_o),
		.dma_ack_i(dma_ack_i), 
		.dma_we_o(dma_we_o),
		.dma_addr_o(dma_addr_o),
		.dma_data_o(dma_data_o)	
	);
endmodule
