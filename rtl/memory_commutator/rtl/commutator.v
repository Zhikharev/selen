// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : commutator.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

module commutator
(
	input sys_clk,
	input sys_rst,

	// CPU instruction interface
	input    				master1_wb_stb_i,
	output 	 				master1_wb_ack_o,
	input 		 			master1_wb_cyc_i,	
	input		[15:0]		master1_wb_addr_i,
	output  	[31:0]		master1_wb_data_o,
	output 					master1_wb_stall_o,


	// CPU data memory interface
	input    				master2_wb_stb_i,
	output 	 				master2_wb_ack_o, 
	input  					master2_wb_we_i,
	input		[15:0] 		master2_wb_addr_i,
	input 		[31:0]		master2_wb_data_i,
	output 		[31:0] 		master2_wb_data_o,

	// IO inteface data
	output    				slave4_wb_stb_o,
	input 	 				slave4_wb_ack_i,
	output          		slave4_wb_we_o,
	output  	[15:0] 		slave4_wb_addr_o,
	input   	[31:0] 		slave4_wb_data_i,
	output  	[31:0] 		slave4_wb_data_o,
	
	// DMA
	output 					master3_wb_cyc_o,
	input    				master3_wb_stb_i,
	output	 	 			master3_wb_ack_o, 
	input  					master3_wb_we_i,
	input		[15:0] 		master3_wb_addr_i,
	input 		[31:0]		master3_wb_data_i,
	output 		[31:0] 		master3_wb_data_o,
	
	// RAM port1 instructions
	output  	   			slave1_wb_stb_o,
	input 					slave1_wb_ack_i,
	output  	[15:0]		slave1_wb_addr_o,
	input 	  	[31:0]		slave1_wb_data_i,
	
	// RAM port2 data
	output 	    			slave2_wb_stb_o,
	input 		 			slave2_wb_ack_i,
	output 	 				slave2_wb_we_o,
	output 		[15:0]		slave2_wb_addr_o,
	output 		[31:0]		slave2_wb_data_o,
	input 		[31:0] 		slave2_wb_data_i,
	
	// ROM 
	output 					slave3_wb_stb_o,
	input 		 			slave3_wb_ack_i,
	output   	[15:0]		slave3_wb_addr_o,
	input 	  	[31:0]		slave3_wb_data_i
);
	/*parameter M_ROM_h = 16'h0000;
	parameter M_ROM_l = 16'h000F;

	parameter M_RAM_h = 16'h0010;
	parameter M_RAM_l = 16'h03FF;

	parameter M_IO_h = 16'h0400;
	parameter M_IO_l = 16'hFFFF;*/
	
	//ROM
	localparam SL3_ADDR = 16'h0000; 
	localparam SL3_MASK = 16'hFFF0;
	
	//RAM
	localparam SL2_ADDR = 16'h4000; 
	localparam SL2_MASK = 16'hC000;
	
	//IO
	localparam SL4_ADDR = 16'h8000; 
	localparam SL4_MASK = 16'h8000;
	
	parameter DEPTH = 3;
	parameter SIZE	= 16;
	
	reg 					m_stb_i;
	reg						m_ack_o; 
	reg  					m_we_i;
	reg  					m_cyc_i;
	reg			[15:0] 		m_addr_i;
	reg 		[31:0]		m_data_i;
	reg			[31:0] 		m_data_o;
	
	//FIFO
	wire full;
	wire empty;
	wire [15:0] fifo_master1_addr;
	
	reg	 			reg_master1_wb_ack_o;
	reg [31:0]		reg_master1_wb_data_o;
	
	reg	 			reg_master2_wb_ack_o; 
	reg	[31:0] 		reg_master2_wb_data_o;
	
	reg   			reg_slave4_wb_stb_o;
	reg        		reg_slave4_wb_we_o;
	reg [15:0] 		reg_slave4_wb_addr_o;
	reg [31:0] 		reg_slave4_wb_data_o;
	
	reg	 			reg_master3_wb_ack_o; 
	reg	[31:0] 		reg_master3_wb_data_o;
	
	reg    			reg_slave1_wb_stb_o;
	reg [15:0]		reg_slave1_wb_addr_o;
	
	reg	    		reg_slave2_wb_stb_o;
	reg	 			reg_slave2_wb_we_o;
	reg	[15:0]		reg_slave2_wb_addr_o;
	reg	[31:0]		reg_slave2_wb_data_o;
	
	reg				reg_slave3_wb_stb_o;
	reg [15:0]		reg_slave3_wb_addr_o;
	
	
	assign master1_wb_ack_o		= reg_master1_wb_ack_o;
	assign master1_wb_data_o	= reg_master1_wb_data_o;
	assign master2_wb_ack_o		= reg_master2_wb_ack_o; 
	assign master2_wb_data_o	= reg_master2_wb_data_o;
	
	assign slave4_wb_stb_o		= reg_slave4_wb_stb_o;
	assign slave4_wb_we_o		= reg_slave4_wb_we_o;
	assign slave4_wb_addr_o		= reg_slave4_wb_addr_o;	
	assign slave4_wb_data_o		= reg_slave4_wb_data_o;
	
	assign master3_wb_ack_o		= reg_master3_wb_ack_o;
	assign master3_wb_data_o	= reg_master3_wb_data_o;
	assign master3_wb_cyc_o		= master1_wb_cyc_i;
	
	assign slave1_wb_stb_o		= reg_slave1_wb_stb_o;
	assign slave1_wb_addr_o		= reg_slave1_wb_addr_o;
	
	assign slave2_wb_stb_o		= reg_slave2_wb_stb_o;
	assign slave2_wb_we_o		= reg_slave2_wb_we_o;
	assign slave2_wb_addr_o		= reg_slave2_wb_addr_o;
	assign slave2_wb_data_o		= reg_slave2_wb_data_o;
	
	assign slave3_wb_stb_o		= reg_slave3_wb_stb_o;
	assign slave3_wb_addr_o		= reg_slave3_wb_addr_o;
	

	
	
	//fifo fifo1(sys_clk, sys_rst, master1_wb_addr_i, fifo_master1_addr, master1_wb_stb_i, ~empty, full, empty);
	
	//fifo fifo (sys_clk, sys_clk, sys_rst, clr, master1_wb_addr_i, master1_wb_stb_i, fifo_master1_addr, re, full, empty, full_n, empty_n, level );
	
	fifo 
	#(
		.DEPTH(DEPTH),
		.SIZE(SIZE)
	) 
	fifo
	(
		.clk(sys_clk),
		.wr_en(master1_wb_stb_i),
		.din(master1_wb_addr_i),		
		.rd_en(1),
		.dout(fifo_master1_addr),		
		.empty(empty),
		.full(full)
	);
	
	//overflow
	assign master1_wb_stall_o = full;

	// cpu_inst <=> ram or rom
	always @(*) begin
		//if ((master1_wb_addr_i > M_ROM_l) && (master1_wb_addr_i < M_ROM_h)) begin
		if (master1_wb_addr_i & SL3_MASK == SL3_ADDR) begin
			//slave1_wb_stb_o 			<= master1_wb_stb_i;
			reg_slave1_wb_stb_o 			<= ~empty;
			reg_master1_wb_ack_o			<= slave1_wb_ack_i;
			reg_slave1_wb_addr_o			<= fifo_master1_addr & (~SL3_MASK);
			reg_master1_wb_data_o			<= slave1_wb_data_i;		
		end else begin
			//slave3_wb_stb_o 			<= master1_wb_stb_i;
			reg_slave3_wb_stb_o 			<= ~empty;
			reg_master1_wb_ack_o			<= slave3_wb_ack_i;
			reg_slave3_wb_addr_o			<= fifo_master1_addr & (~SL2_MASK);
			reg_master1_wb_data_o			<= slave3_wb_data_i;
		end
	end
	
	// cpu_data <=> ram or I/O
	always @(*) begin
		//if ((master1_wb_addr_i > M_RAM_l) && (master1_wb_addr_i < M_RAM_h)) begin
		if (master1_wb_addr_i & SL2_MASK == SL2_ADDR) begin
			reg_slave2_wb_stb_o 			<= m_stb_i;
			m_ack_o							<= slave2_wb_ack_i;
			reg_slave2_wb_we_o				<= m_we_i;
			reg_slave2_wb_addr_o			<= m_addr_i & (~SL2_MASK);
			m_data_o						<= slave2_wb_data_i;		
			reg_slave2_wb_data_o			<= m_data_i;
			
			if (master2_wb_stb_i & master1_wb_cyc_i) begin				
				m_stb_i 					<= master2_wb_stb_i;
				reg_master2_wb_ack_o		<= m_ack_o;
				m_we_i 						<= master2_wb_we_i;
				m_addr_i					<= master2_wb_addr_i;
				m_data_i					<= master2_wb_data_i;
				reg_master2_wb_data_o		<= m_data_o;
			end else begin
				m_stb_i 					<= master3_wb_stb_i;
				reg_master3_wb_ack_o		<= m_ack_o;
				m_we_i 						<= master3_wb_we_i;
				m_addr_i					<= master3_wb_addr_i;
				m_data_i					<= master3_wb_data_i;
				reg_master3_wb_data_o		<= m_data_o;
			end		
		end else begin
			reg_slave4_wb_stb_o 			<= master2_wb_stb_i;
			reg_master2_wb_ack_o			<= slave4_wb_ack_i;
			reg_slave4_wb_we_o				<= master2_wb_we_i;
			reg_slave4_wb_addr_o			<= master2_wb_addr_i & (~SL4_MASK);
			reg_master2_wb_data_o			<= slave4_wb_data_i;
			reg_slave4_wb_data_o			<= master2_wb_data_i;
		end
	end

endmodule

