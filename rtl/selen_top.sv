// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : selen_top.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_SELEN_TOP
`define INC_SELEN_TOP

module selen_top 
(
	input sys_clk,
	input sys_rst,
	input uart_rx,
	input uart_tx
);

	wire 					cpu_wbi_cyc;
	wire 					cpu_wbi_stb;
	wire [31:0] 	cpu_wbi_addr;
	wire  				cpu_wbi_ack;
	wire [31:0] 	cpu_wbi_data;
	wire 					cpu_wbi_stall;

	wire 					cpu_wbd_stb;
	wire          cpu_wbd_we;
	wire [1:0]    cpu_wbd_be;
	wire [31:0]   cpu_wbd_addr;
	wire [31:0] 	cpu_wbd_data_o;
	wire  				cpu_wbd_ack;
	wire [31:0] 	cpu_wbd_data_i;

	wire		   		rom_stb;
	wire 		 			rom_ack;
	wire	 [31:0]	rom_addr;
	wire	 [31:0]	rom_data;

	wire		   		ram_p0_stb;
	wire 		 			ram_p0_ack;
	wire	 [31:0]	ram_p0_addr;
	wire	 [31:0]	ram_p0_data;

	wire		   		ram_p1_stb;
	wire 		 			ram_p1_ack;
	wire	 				ram_p1_we;
	wire	 [31:0]	ram_p1_addr;
	wire	 [31:0]	ram_p1_data_i;
	wire 	 [31:0] ram_p1_data_o;

	wire 					io_wb_stb;
	wire          io_wb_we;
	wire [1:0]    io_wb_be;
	wire [31:0]   io_wb_addr;
	wire [31:0] 	io_wb_data_o;
	wire  				io_wb_ack;
	wire [31:0] 	io_wb_data_i;

	wire          dma_Wb_cyc;
	wire 					dma_wb_stb;
	wire          dma_wb_we;
	wire [1:0]    dma_wb_be;
	wire [31:0]   dma_wb_addr;
	wire [31:0] 	dma_wb_data_o;
	wire  				dma_wb_ack;
	wire [31:0] 	dma_wb_data_i;

	cpu_top cpu 
	(
		.sys_clk 				(sys_clk),
		.sys_rst 				(sys_rst)
		.inst_cyc_out 	(cpu_wbi_cyc),
		.inst_stb_out 	(cpu_wbi_stb),
		.inst_addr_out 	(cpu_wbi_addr),
		.inst_ack_in 		(cpu_wbi_ack),
		.inst_data_in 	(cpu_wbi_data),
		.inst_stall_in 	(cpu_wbi_stall),
		.data_stb_out 	(cpu_wbd_stb),
		.data_we_out 		(cpu_wbd_we),
		.data_be_out 		(cpu_wbd_be),
		.data_ack_in 		(cpu_wbd_ack),
		.data_addr_out 	(cpu_wbd_addr),
		.data_data_out 	(cpu_wbd_data_o),
		.data_data_in 	(cpu_wbd_data_i)
	);

	wb_comm comm
	(
		.sys_clk 					(sys_clk),
		.sys_rst 					(sys_rst),
		
		.cpu_inst_stb_i 	(cpu_wbi_stb),
		.cpu_inst_ack_o 	(cpu_wbi_ack), 
		.cpu_inst_cyc_i 	(cpu_wbi_cyc), 
		.cpu_inst_addr_i 	(cpu_wbi_addr),
		.cpu_inst_data_o 	(cpu_wbi_data),
		.cpu_inst_stall_o (cpu_wbi_stall),

		.cpu_data_stb_i 	(cpu_wbd_stb),
		.cpu_data_ack_o 	(cpu_wbd_ack), 
		.cpu_data_we_i 		(cpu_wbd_we),
		.cpu_data_addr_i 	(cpu_wbd_addr),
		.cpu_data_data_i  (cpu_wbd_data_o),
		.cpu_data_data_o  (cpu_wbd_data_i),

		.io_stb_o 				(io_wb_stb),
		.io_ack_i 				(io_wb_ack),
		.io_we_o 					(io_wb_we),
		.io_addr_o 				(io_wb_addr),
		.io_data_i 				(io_wb_data_o),
		.io_data_o 				(io_wb_data_i),
	
		.dma_stb_i 				(dma_wb_stb),
		.dma_ack_o 				(dma_wb_ack), 
		.dma_we_i 				(dma_wb_we),
		.dma_addr_i 			(dma_wb_addr),
		.dma_data_i 			(dma_wb_data_o),
		.dma_data_o 			(dma_wb_data_i),
	
		.ram_stb_o 				(ram_p0_stb),
		.ram_ack_i 				(ram_p0_ack),
		.ram_addr_o 			(ram_p0_addr),
		.ram_data_i 			(ram_p0_data),
	
		.ram2_stb_o 			(ram_p1_stb),
		.ram2_ack_i 			(ram_p1_ack),
		.ram2_we_o 				(ram_p1_we),
	 	.ram2_addr_o 			(ram_p1_addr),
		.ram2_data_o 			(ram_p1_data_i),
		.ram2_data_i 			(ram_p1_data_o),
	 
		.rom_stb_o 				(rom_stb),
		.rom_ack_i 				(rom_ack),
		.rom_addr_o 			(rom_addr),
		.rom_data_i 			(rom_data)
	);

	io_top iohub
	(
		.sys_clk 		(sys_clk),
		.sys_rst 		(sys_rst),
		
		.rx 				(uart_rx),
		.tx 				(uart_tx),
		
		.io_stb_i 	(io_wb_stb),
		.io_ack_o 	(io_wb_ack),
		.io_we_i 		(io_wb_we), 
		.io_addr_i 	(io_wb_addr),
		.io_data_o 	(io_wb_data_o),
		.io_data_i 	(io_wb_data_i),
		
		.dma_cyc_i 	(dma_Wb_cyc),
		.dma_stb_o 	(dma_wb_stb),
		.dma_ack_i	(dma_wb_ack), 
		.dma_we_o 	(dma_wb_we),
		.dma_addr_o (dma_wb_data),
		.dma_data_i (dma_wb_data_i),
		.dma_data_o (dma_wb_data_o)
);


	rom rom 
	(
		.sys_clk 	  (sys_clk),
		.sys_rst 	  (sys_rst),
		.rom_stb_i  (rom_stb),
		.rom_ack_o  (rom_ack),
		.rom_addr_i (rom_addr),
		.rom_data_o (rom_data)
	);

	ram ram
	(
		.sys_clk  	 (sys_clk),
		
		.ram_stb_i 	 (ram_p0_stb),
		.ram_ack_o 	 (ram_p0_ack),
		.ram_addr_i  (ram_p0_addr),
		.ram_data_o  (ram_p0_data),
	
		.ram2_stb_i  (ram_p1_stb),
		.ram2_ack_o  (ram_p1_ack), 
		.ram2_we_i 	 (ram_p1_we),
		.ram2_addr_i (ram_p1_addr),
		.ram2_data_i (ram_p1_data_i),
		.ram2_data_o (ram_p1_data_o)
);


endmodule

`endif