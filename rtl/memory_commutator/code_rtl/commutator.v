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

module commutator(
	input sys_clk,
	input sys_rst,

	// CPU instruction interface
	input    				master1_wb_stb_i,
	output reg	 			master1_wb_ack_o, 
	input		  	[15:0]	master1_wb_addr_i,
	output reg 	[31:0]	master1_wb_data_i,


	// CPU data memory interface
	input    				master2_wb_stb_i,
	output reg	 			master2_wb_ack_o, 
	input  					master2_wb_we_i,
	input			[15:0] 	master2_wb_addr_i,
	input 		[31:0]	master2_wb_data_i,
	output reg	[31:0] 	master2_wb_data_o,

	// IO inteface data
	output reg   			slave4_wb_stb_o,
	input 	 				slave4_wb_ack_i,
	output reg         	slave4_wb_we_o,
	output reg 	[15:0] 	slave4_wb_addr_o,
	input   		[31:0] 	slave4_wb_data_i,
	output reg 	[31:0] 	slave4_wb_data_o,
	
	// DMA
	input    				master3_wb_stb_i,
	output reg	 			master3_wb_ack_o, 
	input  					master3_wb_we_i,
	input			[15:0] 	master3_wb_addr_i,
	input 		[31:0]	master3_wb_data_i,
	output reg	[31:0] 	master3_wb_data_o,
	
	// RAM port1 instructions
	output reg    			slave1_wb_stb_o,
	input 					slave1_wb_ack_i,
	output reg [15:0]		slave1_wb_addr_o,
	input 	  [31:0]		slave1_wb_data_i,
	
	// RAM port2 data
	output reg	    		slave2_wb_stb_o,
	input 		 			slave2_wb_ack_i,
	output reg	 			slave2_wb_we_o,
	output reg	[15:0]	slave2_wb_addr_o,
	output reg	[31:0]	slave2_wb_data_o,
	input 		[31:0] 	slave2_wb_data_i,
	
	// ROM 
	output reg				slave3_wb_stb_o,
	input 		 			slave3_wb_ack_i,
	output reg [15:0]		slave3_wb_addr_o,
	input 	  [31:0]		slave3_wb_data_i
);
	
	
	reg 				m_stb_i;
	reg				m_ack_o; 
	reg  				m_we_i;
	reg  				m_cyc_i;
	reg	[15:0] 	m_addr_i;
	reg 	[31:0]	m_data_i;
	reg	[31:0] 	m_data_o;
	
	// cpu_inst => ram or rom
	always @(posedge sys_clk) begin
		if (master1_wb_addr_i[15]) begin
			slave1_wb_stb_o 			= master1_wb_stb_i;
			master1_wb_ack_o		= slave1_wb_ack_i;
			slave1_wb_addr_o			= master1_wb_addr_i;
			master1_wb_data_i	= slave1_wb_data_i;		
		end else begin
			slave3_wb_stb_o 			= master1_wb_stb_i;
			master1_wb_ack_o		= slave3_wb_ack_i;
			slave3_wb_addr_o			= master1_wb_addr_i;
			master1_wb_data_i	= slave3_wb_data_i;
		end
	end
	
	// cpu_data => ram or I/O
	always @(posedge sys_clk) begin
		if (master2_wb_addr_i[15]) begin
			slave2_wb_stb_o 			= m_stb_i;
			m_ack_o				= slave2_wb_ack_i;
			slave2_wb_we_o			= m_we_i;
			slave2_wb_addr_o			= m_addr_i;
			m_data_o				= slave2_wb_data_i;		
			slave2_wb_data_o			= m_data_i;
			
			if (master3_wb_stb_i) begin
				m_stb_i 				= master3_wb_stb_i;
				master3_wb_ack_o			= m_ack_o;
				m_we_i 				= master3_wb_we_i;
				m_addr_i				= master3_wb_addr_i;
				m_data_i				= master3_wb_data_i;
				master3_wb_data_o			= m_data_o;
			end else begin
				m_stb_i 				= master2_wb_stb_i;
				master2_wb_ack_o		= m_ack_o;
				m_we_i 				= master2_wb_we_i;
				m_addr_i				= master2_wb_addr_i;
				m_data_i				= master2_wb_data_i;
				master2_wb_data_o	= m_data_o;
			end			
		end else begin
			slave4_wb_stb_o 			= master2_wb_stb_i;
			master2_wb_ack_o		= slave4_wb_ack_i;
			slave4_wb_we_o				= master2_wb_we_i;
			slave4_wb_addr_o			= master2_wb_addr_i;
			master2_wb_data_o	= slave4_wb_data_i;
			slave4_wb_data_o			= master2_wb_data_i;
		end
	end

endmodule

