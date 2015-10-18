// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : wapper_commutator.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

module wapper_commutator(
	input sys_clk,
	input sys_rst,

	// CPU instruction interface
	input    				cpu_inst_stb_i,
	output 	 			cpu_inst_ack_o, 
	input		  	[15:0]	cpu_inst_addr_i,
	output  	[31:0]	cpu_inst_data_o,


	// CPU data memory interface
	input    				cpu_data_stb_i,
	output 	 			cpu_data_ack_o, 
	input  					cpu_data_we_i,
	input			[15:0] 	cpu_data_addr_i,
	input 		[31:0]	cpu_data_data_i,
	output 	[31:0] 	cpu_data_data_o,

	// IO inteface data
	output    			io_stb_o,
	input 	 				io_ack_i,
	output          	io_we_o,
	output  	[15:0] 	io_addr_o,
	input   		[31:0] 	io_data_i,
	output  	[31:0] 	io_data_o,
	
	// DMA
	input    				dma_stb_i,
	output 	 			dma_ack_o, 
	input  					dma_we_i,
	input			[15:0] 	dma_addr_i,
	input 		[31:0]	dma_data_i,
	output 	[31:0] 	dma_data_o,
	
	// RAM port1 instructions
	output     			ram_stb_o,
	input 					ram_ack_i,
	output  [15:0]		ram_addr_o,
	input 	  [31:0]		ram_data_i,
	
	// RAM port2 data
	output 	    		ram2_stb_o,
	input 		 			ram2_ack_i,
	output 	 			ram2_we_o,
	output 	[15:0]	ram2_addr_o,
	output 	[31:0]	ram2_data_o,
	input 		[31:0] 	ram2_data_i,
	
	// ROM 
	output 				rom_stb_o,
	input 		 			rom_ack_i,
	output  [15:0]		rom_addr_o,
	input 	  [31:0]		rom_data_i
);

	commutator com( sys_clk, sys_rst, cpu_inst_stb_i, cpu_inst_ack_o, cpu_inst_addr_i, cpu_inst_data_o, 
								cpu_data_stb_i,	cpu_data_ack_o, cpu_data_we_i, cpu_data_addr_i, cpu_data_data_i, cpu_data_data_o,
								io_stb_o, io_ack_i,io_we_o, io_addr_o, io_data_i, io_data_o,
								dma_stb_i, dma_ack_o, dma_we_i, dma_addr_i, dma_data_i, dma_data_o,
								ram_stb_o, ram_ack_i, ram_addr_o, ram_data_i, 
								ram2_stb_o, ram2_ack_i,	ram2_we_o, ram2_addr_o, ram2_data_o, ram2_data_i,
								rom_stb_o, rom_ack_i, rom_addr_o, rom_data_i								
	);
endmodule

