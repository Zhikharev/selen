module decode(
	input clk,
	input rst,
	input rx,
	output reg [31:0] dout,
	output reg data_ready
);
	//uart
    wire receive; // Indicated that a byte has been received.
    wire [7:0] rx_byte; // Byte received
    wire recv_error; // Indicates error in receiving packet.
	
	//fifo
	parameter DEPTH = 3;
	parameter SIZE	= 8;
	
	//reg wr_en;
	
	reg rd_en;
	wire [SIZE-1:0] d_fifo_out;	
	wire empty;
	wire full;
	wire is_receiving;
	
	reg [1:0]state_reg, state_next;
	
	uart uart_rx(
		.clk(clk), // The master clock for this module
		.rst(rst), // Synchronous reset.
		.rx(rx), // Incoming serial line
		.tx(), // Outgoing serial line
		.transmit(), // Signal to transmit
		.tx_byte(), // Byte to transmit
		.received(receive), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(), // Low when transmit line is idle.
		.recv_error(recv_error) // Indicates error in receiving packet.
    );

	/*fifo 
	#(
		.DEPTH(DEPTH),
		.SIZE(SIZE)
	) 
	fifo
	(
		.clk(clk),
		.wr_en(receive),
		.din(rx_byte),		
		.rd_en(1),
		.dout(d_fifo_out),		
		.empty(empty),
		.full(full)
	);*/
	
	localparam byte_0 = 0;
	localparam byte_1 = 1;
	localparam byte_2 = 2;
	localparam byte_3 = 3;
	
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_next = byte_0;
			state_reg  = byte_0;
			data_ready = 1'b0;
		end else begin
			if ((receive) & (state_reg == byte_0)) dout[7:0] 	<= rx_byte; 
			if ((receive) & (state_reg == byte_1)) dout[15:8]	<= rx_byte;
			if ((receive) & (state_reg == byte_2)) dout[23:16]	<= rx_byte;
			if ((receive) & (state_reg == byte_3)) dout[31:24] 	<= rx_byte;
			
			if ((state_reg == byte_3) & (state_next == byte_0)) data_ready <= 1'b1;
			if ((state_reg == byte_0) & (state_next == byte_0)) data_ready <= 1'b0;
			
			if (is_receiving) state_reg <= state_next;
		end
	end
	
	always @(*) begin
		case (state_reg) 
			byte_0:if (receive) state_next = byte_1;
			byte_1:if (receive) state_next = byte_2;
			byte_2:if (receive) state_next = byte_3;
			byte_3:if (receive) state_next = byte_0;
			default: state_next = byte_0;
		endcase
	end
	
endmodule
