// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : comm.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : Top level memory commutator.
// ----------------------------------------------------------------------------

module comm(
	input sys_clk,
	input sys_rst,

	// CPU instruction interface
	input    				cpu_inst_stb_i,
	output 	 				cpu_inst_ack_o, 
	input 	 				cpu_inst_cyc_i, 
	input		[15:0]		cpu_inst_addr_i,
	output  	[31:0]		cpu_inst_data_o,
	input 					cpu_inst_stall_o,


	// CPU data memory interface
	input    			cpu_data_stb_i,
	output 		 		cpu_data_ack_o, 
	input  				cpu_data_we_i,
	input	[15:0]	 	cpu_data_addr_i,
	input 	[31:0]		cpu_data_data_i,
	output 	[31:0] 		cpu_data_data_o
);

	// IO inteface data
	wire   				io_stb_o;
	wire 	 			io_ack_i;
	wire         		io_we_o;
	wire 	[15:0] 		io_addr_o;
	wire  	[31:0] 		io_data_i;
	wire 	[31:0] 		io_data_o;
	
	// DMA
	wire 				dma_cyc_i;
	wire  				dma_stb_i;
	wire				dma_ack_o; 
	wire  				dma_we_i;
	wire	[15:0] 		dma_addr_i;
	wire 	[31:0]		dma_data_i;
	wire	[31:0]	 	dma_data_o;
	
	// RAM port1 instructions
	wire    			ram_stb_o;
	wire 				ram_ack_i;
	wire 	[15:0]		ram_addr_o;
	wire 	[31:0]		ram_data_i;
	
	// RAM port2 data
	wire	    		ram2_stb_o;
	wire 		 		ram2_ack_i;
	wire	 			ram2_we_o;
	wire	[15:0]		ram2_addr_o;
	wire	[31:0]		ram2_data_o;
	wire 	[31:0] 		ram2_data_i;
	
	// ROM 
	wire				rom_stb_o;
	wire 	 			rom_ack_i;
	wire 	[15:0]		rom_addr_o;
	wire  	[31:0]		rom_data_i;
	
	wb_comm wb_com( sys_clk, sys_rst, cpu_inst_stb_i, cpu_inst_ack_o, cpu_inst_cyc_i, cpu_inst_addr_i, cpu_inst_data_o, cpu_inst_stall_o,
									cpu_data_stb_i,	cpu_data_ack_o, cpu_data_we_i, cpu_data_addr_i, cpu_data_data_i, cpu_data_data_o,
									io_stb_o, io_ack_i,io_we_o, io_addr_o, io_data_i, io_data_o,
									dma_cyc_i, dma_stb_i, dma_ack_o, dma_we_i, dma_addr_i, dma_data_i, dma_data_o,
									ram_stb_o, ram_ack_i, ram_addr_o, ram_data_i, 
									ram2_stb_o, ram2_ack_i,	ram2_we_o, ram2_addr_o, ram2_data_o, ram2_data_i,
									rom_stb_o, rom_ack_i, rom_addr_o, rom_data_i								
	);
	
	ram ram1( sys_clk, ram_stb_o, ram_ack_i, ram_addr_o, ram_data_i,
					  ram2_stb_o, ram2_ack_i, ram2_we_o, ram2_addr_o, ram2_data_o, ram2_data_i
	);
	
	rom rom1( sys_clk, sys_rst, rom_stb_o, rom_ack_i, rom_addr_o, rom_data_i);

endmodule
