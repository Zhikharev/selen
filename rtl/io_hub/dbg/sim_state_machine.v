module sim_state_machine();

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
	
	reg dready;
	reg  [31:0] din;
	wire [31:0] data;
	wire [31:0] status_reg;
	wire [31:0] addr_first_reg;
	wire [31:0] addr_end_reg;
	
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
		
	state_mashine state_mashine(
		.clk(clk),
		.rst(rst),
		.dready(dready),
		.din(din),
		.data(data),
		.status_reg(status_reg),
		.addr_first_reg(addr_first_reg),
		.addr_end_reg(addr_end_reg)
	);
	
	initial begin 
		clk = 1;
		forever 
			#1 clk = ~clk;
	end
	
	initial begin
		forever begin
			#1 rx = tx;
			din = dout;
			dready = data_ready;
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
		/*transmit = 1;
		tx_byte = 8'h01;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		transmit = 0;
		
		//#1000;
		
		transmit = 1;
		tx_byte = 8'h02;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		transmit = 0;
		
		transmit = 1;
		tx_byte = 8'h04;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		transmit = 0;*/
		
		send(32'h00000001);
		
		send(32'h00000003);
		send(32'h11111111);
		
		send(32'h00000004);
		send(32'h22222222);
		
		send(32'h00000005);
		send(32'h33333333);
		
		send(32'h00000005);
		send(32'hAAAAAAAA);
		/*transmit = 1;
		tx_byte = 8'h03;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		tx_byte = 8'h00;
		@(negedge is_transmitting);
		transmit = 0;		
		
		transmit = 1;
		tx_byte = 8'h11;
		@(negedge is_transmitting);
		tx_byte = 8'h22;
		@(negedge is_transmitting);
		tx_byte = 8'h33;
		@(negedge is_transmitting);
		tx_byte = 8'h44;
		@(negedge is_transmitting);
		transmit = 0;*/
	end
	
	
	
endmodule
