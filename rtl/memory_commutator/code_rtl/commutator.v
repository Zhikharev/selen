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
	parameter M_ROM_h = 16'h0000;
	parameter M_ROM_l = 16'h000C;

	parameter M_RAM_h = 16'h0200;
	parameter M_RAM_l = 16'h03FF;

	parameter M_IO_h = 16'h0400;
	parameter M_IO_l = 16'hFFFF;
	
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
	assign slave1_wb_stb_o		= reg_slave1_wb_stb_o;
	assign slave1_wb_addr_o		= reg_slave1_wb_addr_o;
	assign slave2_wb_stb_o		= reg_slave2_wb_stb_o;
	assign slave2_wb_we_o		= reg_slave2_wb_we_o;
	assign slave2_wb_addr_o		= reg_slave2_wb_addr_o;
	assign slave2_wb_data_o		= reg_slave2_wb_data_o;
	assign slave3_wb_stb_o		= reg_slave3_wb_stb_o;
	assign slave3_wb_addr_o		= reg_slave3_wb_addr_o;
	

	
	
	fifo fifo1(sys_rst, sys_clk, sys_clk, master1_wb_addr_i, ~empty, ~full, fifo_master1_addr, full, empty);
	//overflow
	assign master1_wb_stall_o = full;

	// cpu_inst <=> ram or rom
	always @(*) begin
		if ((master1_wb_addr_i > M_ROM_l) && (master1_wb_addr_i < M_ROM_h)) begin
			//slave1_wb_stb_o 			<= master1_wb_stb_i;
			reg_slave1_wb_stb_o 			<= ~empty;
			reg_master1_wb_ack_o			<= slave1_wb_ack_i;
			reg_slave1_wb_addr_o			<= fifo_master1_addr;
			reg_master1_wb_data_o			<= slave1_wb_data_i;		
		end else begin
			//slave3_wb_stb_o 			<= master1_wb_stb_i;
			reg_slave3_wb_stb_o 			<= ~empty;
			reg_master1_wb_ack_o			<= slave3_wb_ack_i;
			reg_slave3_wb_addr_o			<= fifo_master1_addr;
			reg_master1_wb_data_o			<= slave3_wb_data_i;
		end
	end
	
	// cpu_data <=> ram or I/O
	always @(*) begin
		if ((master1_wb_addr_i > M_RAM_l) && (master1_wb_addr_i < M_RAM_h)) begin
			reg_slave2_wb_stb_o 			<= m_stb_i;
			m_ack_o						<= slave2_wb_ack_i;
			reg_slave2_wb_we_o				<= m_we_i;
			reg_slave2_wb_addr_o			<= m_addr_i;
			m_data_o					<= slave2_wb_data_i;		
			reg_slave2_wb_data_o			<= m_data_i;
			
			if (master2_wb_stb_i) begin				
				m_stb_i 				<= master2_wb_stb_i;
				reg_master2_wb_ack_o		<= m_ack_o;
				m_we_i 					<= master2_wb_we_i;
				m_addr_i				<= master2_wb_addr_i;
				m_data_i				<= master2_wb_data_i;
				reg_master2_wb_data_o		<= m_data_o;
			end else begin
				m_stb_i 				<= master3_wb_stb_i;
				reg_master3_wb_ack_o		<= m_ack_o;
				m_we_i 					<= master3_wb_we_i;
				m_addr_i				<= master3_wb_addr_i;
				m_data_i				<= master3_wb_data_i;
				reg_master3_wb_data_o		<= m_data_o;
			end		
		end else begin
			reg_slave4_wb_stb_o 			<= master2_wb_stb_i;
			reg_master2_wb_ack_o			<= slave4_wb_ack_i;
			reg_slave4_wb_we_o				<= master2_wb_we_i;
			reg_slave4_wb_addr_o			<= master2_wb_addr_i;
			reg_master2_wb_data_o			<= slave4_wb_data_i;
			reg_slave4_wb_data_o			<= master2_wb_data_i;
		end
	end

endmodule

