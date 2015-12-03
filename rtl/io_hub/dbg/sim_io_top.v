// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : sim_io_top.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

module sim_io_top();

	reg clk;
	reg rst;
	reg rx;

    wire tx; // Outgoing serial line
    reg transmit; // Signal to transmit
    reg [7:0] tx_byte; // Byte to transmit
    wire is_transmitting; // Low when transmit line is idle.
    wire recv_error; // Indicates error in receiving packet.

	// IO inteface data
	reg  				io_stb_i;
	wire 	 			io_ack_o;
	reg         		io_we_i;
	reg 	[15:0] 		io_addr_i;
	wire 	[31:0] 		io_data_o;

	// DMA
	reg 				dma_cyc_i;
	wire 				dma_stb_o;
	reg					dma_ack_i; 
	wire 				dma_we_o;
	wire	[15:0] 		dma_addr_o;
	wire 	[31:0]		dma_data_o;
	
	uart uart_rx(
		.clk(clk), // The master clock for this module
		.rst(rst), // Synchronous reset.
		.rx(), // Incoming serial line
		.tx(tx), // Outgoing serial line
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(), // Indicated that a byte has been received.
		.rx_byte(), // Byte received
		.is_receiving(), // Low when receive line is idle.
		.is_transmitting(is_transmitting), // Low when transmit line is idle.
		.recv_error(recv_error) // Indicates error in receiving packet.
    );
	
	io_top io_top(
		.clk(clk),
		.rst(rst),
		
		//UART
		.rx(rx),
		.tx(tx),
		
		//IO inteface data
		.io_stb_i(io_stb_i),
		.io_ack_o(io_ack_o),
		.io_we_i(io_we_i),
		.io_addr_i(io_addr_i),
		.io_data_o(io_data_o),
		.io_data_i(),
		
		// DMA
		.dma_cyc_i(dma_cyc_i),
		.dma_stb_o(dma_stb_o),
		.dma_ack_i(dma_ack_i), 
		.dma_we_o(dma_we_o),
		.dma_addr_o(dma_addr_o),
		.dma_data_o(dma_data_o)
	);

	
	initial begin 
		clk = 1;
		forever 
			#1 clk = ~clk;
	end
	
	initial begin
		io_stb_i  = 0;
		dma_cyc_i = 0;
		dma_ack_i = 0;
		forever begin
			#1 rx = tx;
		end
	end
	
	task send;
		input [31:0] data;
		begin
			transmit = 1;
			tx_byte = data[7:0];
			@(negedge is_transmitting);
			tx_byte = data[15:8];
			@(negedge is_transmitting);
			tx_byte = data[23:16];
			@(negedge is_transmitting);
			tx_byte = data[31:24];
			@(negedge is_transmitting);
			transmit = 0;
		end
	endtask
	
	initial begin
		rst = 1;
		#20 rst = 0;
/*		
		send(32'h00000001);
		
		send(32'h00000003);
		send(32'h11111111);*/
		
		send(32'h00000004);
		send(32'h00002222);
		
		send(32'h00000005);
		send(32'h33333333);
		
		send(32'h00000005);
		send(32'hAAAAAAAA);
		
		send(32'h00000005);
		send(32'hBBBBBBBB);
		
		send(32'h00000005);
		send(32'hCCCCCCCC);
		
		dma_cyc_i = 1;
		#2 dma_ack_i = 1;
		
		io_stb_i = 1;
		io_addr_i = 16'h0003;
	end
	
	
	
endmodule
