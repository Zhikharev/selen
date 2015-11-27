module io_hub(
		input clk,
		input rst,
		input [31:0] data,
		input [31:0] status_reg,
		input [31:0] addr_first_reg,
		input [31:0] addr_end_reg,
		
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
	
	reg [31:0] r_io_data_o;
	
	reg r_dma_stb_o;
	reg r_dma_we_o;
	reg [15:0] r_dma_addr_o;
	reg [31:0] r_dma_data_o;
	
	//fifo
	parameter DEPTH = 3;
	parameter SIZE	= 32;
	
	//reg wr_en;	
	reg rd_en;
	wire [SIZE-1:0] d_fifo_out;	
	wire empty;
	wire full;
	wire is_receiving;
	
	
	
	fifo 
	#(
		.DEPTH(DEPTH),
		.SIZE(SIZE)
	) 
	fifo
	(
		.clk(clk),
		.wr_en(status_reg[2]),
		.din(data),		
		.rd_en(dma_cyc_i & dma_ack_i),
		.dout(d_fifo_out),		
		.empty(empty),
		.full(full)
	);
	
	//master DMA	
	reg [15:0] counter;
	
	assign dma_stb_o  = r_dma_stb_o;
	assign dma_we_o   = r_dma_we_o;
	assign dma_addr_o = r_dma_addr_o;
	assign dma_data_o = d_fifo_out;
	
	always @(posedge clk) begin
		if (rst) begin
			r_dma_stb_o 	= 0;
			r_dma_we_o  	= 0;
			r_dma_addr_o	= 16'h0000;
			r_dma_data_o	= 32'h00000000;
			counter 	= 16'h0000;
		end else begin
			if ((dma_cyc_i) & (~empty) & (r_dma_addr_o <= addr_end_reg)) begin
				r_dma_stb_o 	= 1;
				if (dma_ack_i) begin
					r_dma_we_o  	= 1;
					r_dma_addr_o	= addr_first_reg + counter;
					counter 		= counter + 1'b1;
				end else
					r_dma_we_o  	= 0;
			end else begin
				r_dma_stb_o			= 0;
				r_dma_we_o		  	= 0;
			end
		end
	end
	
	
	//slave IO	
	localparam status_addr = 16'h0001;
	localparam addr_first_addr = 16'h0002;
	localparam addr_end_addr = 16'h0003;
	
	assign io_ack_o  = io_stb_i;
	assign io_data_o = r_io_data_o;
	
	always @(posedge clk) begin
		if (rst) begin
			r_io_data_o	= 32'h00000000;
		end else begin
			if (io_stb_i) begin
				case (io_addr_i)
					status_addr: 	 r_io_data_o	<= status_reg;
					addr_first_addr: r_io_data_o	<= addr_first_reg;
					addr_end_addr:   r_io_data_o	<= addr_end_reg;
					default: r_io_data_o	<= 32'h00000000;
				endcase
			end
		end
	end
endmodule

