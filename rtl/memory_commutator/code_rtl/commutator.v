/*
###########################################################
#
# Author: Sokolovskii Artem
#
# Project: MEPHI CPU
# Filename: commutator.v
# Descriptions:
#
###########################################################
*/
module commutator(
	input sys_clk,
	input sys_rst,

	// CPU instruction interface
	input    				cpu_inst_stb_i,
	output reg	 			cpu_inst_ack_o, 
	input		  	[15:0]	cpu_inst_addr_i,
	output reg 	[31:0]	cpu_inst_data_o,


	// CPU data memory interface
	input    				cpu_data_stb_i,
	output reg	 			cpu_data_ack_o, 
	input  					cpu_data_we_i,
	input			[15:0] 	cpu_data_addr_i,
	input 		[31:0]	cpu_data_data_i,
	output reg	[31:0] 	cpu_data_data_o,

	// IO inteface data
	output reg   			io_stb_o,
	input 	 				io_ack_i,
	output reg         	io_we_o,
	output reg 	[15:0] 	io_addr_o,
	input   		[31:0] 	io_data_i,
	output reg 	[31:0] 	io_data_o,
	
	// DMA
	input    				dma_stb_i,
	output reg	 			dma_ack_o, 
	input  					dma_we_i,
	input			[15:0] 	dma_addr_i,
	input 		[31:0]	dma_data_i,
	output reg	[31:0] 	dma_data_o,
	
	// RAM port1 instructions
	output reg    			ram_stb_o,
	input 					ram_ack_i,
	output reg [15:0]		ram_addr_o,
	input 	  [31:0]		ram_data_i,
	
	// RAM port2 data
	output reg	    		ram2_stb_o,
	input 		 			ram2_ack_i,
	output reg	 			ram2_we_o,
	output reg	[15:0]	ram2_addr_o,
	output reg	[31:0]	ram2_data_o,
	input 		[31:0] 	ram2_data_i,
	
	// ROM 
	output reg				rom_stb_o,
	input 		 			rom_ack_i,
	output reg [15:0]		rom_addr_o,
	input 	  [31:0]		rom_data_i
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
		if (cpu_inst_addr_i[15]) begin
			ram_stb_o 			= cpu_inst_stb_i;
			cpu_inst_ack_o		= ram_ack_i;
			ram_addr_o			= cpu_inst_addr_i;
			cpu_inst_data_o	= ram_data_i;		
		end else begin
			rom_stb_o 			= cpu_inst_stb_i;
			cpu_inst_ack_o		= rom_ack_i;
			rom_addr_o			= cpu_inst_addr_i;
			cpu_inst_data_o	= rom_data_i;
		end
	end
	
	// cpu_data => ram or I/O
	always @(posedge sys_clk) begin
		if (cpu_data_addr_i[15]) begin
			ram2_stb_o 			= m_stb_i;
			m_ack_o				= ram2_ack_i;
			ram2_we_o			= m_we_i;
			ram2_addr_o			= m_addr_i;
			m_data_o				= ram2_data_i;		
			ram2_data_o			= m_data_i;
			
			if (dma_stb_i) begin
				m_stb_i 				= dma_stb_i;
				dma_ack_o			= m_ack_o;
				m_we_i 				= dma_we_i;
				m_addr_i				= dma_addr_i;
				m_data_i				= dma_data_i;
				dma_data_o			= m_data_o;
			end else begin
				m_stb_i 				= cpu_data_stb_i;
				cpu_data_ack_o		= m_ack_o;
				m_we_i 				= cpu_data_we_i;
				m_addr_i				= cpu_data_addr_i;
				m_data_i				= cpu_data_data_i;
				cpu_data_data_o	= m_data_o;
			end			
		end else begin
			io_stb_o 			= cpu_data_stb_i;
			cpu_data_ack_o		= io_ack_i;
			io_we_o				= cpu_data_we_i;
			io_addr_o			= cpu_data_addr_i;
			cpu_data_data_o	= io_data_i;
			io_data_o			= cpu_data_data_i;
		end
	end

endmodule

