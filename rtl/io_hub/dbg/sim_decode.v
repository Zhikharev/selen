module sim_decode();

	reg clk;
	reg rst;
	reg rx;
	wire [31:0] dout;
	wire data_ready;

    wire tx; // Outgoing serial line
    reg transmit; // Signal to transmit
    reg [7:0] tx_byte; // Byte to transmit
    wire is_transmitting; // Low when transmit line is idle.
    wire recv_error; // Indicates error in receiving packet.
	
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
	
	decode decode(
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.dout(dout),
		.data_ready(data_ready)
	);
	
	
	initial begin 
		clk = 1;
		forever 
			#1 clk = ~clk;
	end
	
	initial begin
		forever
			#1 rx = tx;
	end
	
	initial begin
		rst = 1;
		#20 rst = 0;
		transmit = 1;
		tx_byte = 8'h01;
		@(negedge is_transmitting);
		tx_byte = 8'h02;
		@(negedge is_transmitting);
		tx_byte = 8'h03;
		@(negedge is_transmitting);
		tx_byte = 8'h04;
		@(negedge is_transmitting);
		transmit = 0;
		
		#1000;
		
		transmit = 1;
		tx_byte = 8'h11;
		@(negedge is_transmitting);
		tx_byte = 8'h22;
		@(negedge is_transmitting);
		tx_byte = 8'h33;
		@(negedge is_transmitting);
		tx_byte = 8'h44;
		@(negedge is_transmitting);
		transmit = 0;
	end
	
	
	
endmodule
