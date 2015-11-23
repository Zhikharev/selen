
module sim_uart();

	reg clk; // The master clock for this module
    reg rst; // Synchronous reset.
    reg rx; // Incoming serial line
    wire tx; // Outgoing serial line
    reg transmit; // Signal to transmit
    reg [7:0] tx_byte; // Byte to transmit
    wire received; // Indicated that a byte has been received.
    wire [7:0] rx_byte; // Byte received
    wire is_receiving; // Low when receive line is idle.
    wire is_transmitting; // Low when transmit line is idle.
    wire recv_error; // Indicates error in receiving packet.
	
	uart uart_rx(
		.clk(clk), // The master clock for this module
		.rst(rst), // Synchronous reset.
		.rx(rx), // Incoming serial line
		.tx(tx), // Outgoing serial line
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(receive), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting), // Low when transmit line is idle.
		.recv_error(recv_error) // Indicates error in receiving packet.
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
		tx_byte = 8'h55;
	end
	
endmodule
