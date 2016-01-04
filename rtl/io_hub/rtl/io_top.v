// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : io_top.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : Top level I/O Hub.
// ----------------------------------------------------------------------------

module io_top(
		input sys_clk,
		input sys_rst,
		
		//UART
		input rx,
		input tx,
		
		//IO inteface data
		input  				io_stb_i,
		output 	 			io_ack_o,
		input         		io_we_i,
		input 	[31:0] 		io_addr_i,
		output 	[31:0] 		io_data_i,
		output 	[31:0] 		io_data_o,
		
		// DMA
		output 				dma_cyc_o,
		output 				dma_stb_o,
		input				dma_ack_i, 
		output 				dma_we_o,
		output	[31:0] 		dma_addr_o,
		output 	[31:0] 		dma_data_i,
		output 	[31:0]		dma_data_o
);

	wire [31:0] dout;
	wire data_ready;

	wire [31:0] data;
	wire [31:0] status_reg;
	wire [31:0] addr_first_reg;
	wire [31:0] addr_end_reg;
	
	decode decode(
		.clk(sys_clk),
		.rst(sys_rst),
		.rx(rx),
		.dout(dout),
		.data_ready(data_ready)
	);
		
	state_mashine state_mashine(
		.clk(sys_clk),
		.rst(sys_rst),
		.dready(data_ready),
		.din(dout),
		.data(data),
		.status_reg(status_reg),
		.addr_first_reg(addr_first_reg),
		.addr_end_reg(addr_end_reg)
	);
	
	io_hub io_hub(
		.clk(sys_clk),
		.rst(sys_rst),
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
		.dma_cyc_o(dma_cyc_o),
		.dma_stb_o(dma_stb_o),
		.dma_ack_i(dma_ack_i), 
		.dma_we_o(dma_we_o),
		.dma_addr_o(dma_addr_o),
		.dma_data_o(dma_data_o)	
	);
endmodule
