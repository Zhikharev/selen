// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sram_rom.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : SRAM read only verilog model, syncronous read
// ----------------------------------------------------------------------------

`ifndef INC_SRAM_ROM
`define INC_SRAM_ROM

module sram_rom
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
)
(
	input 										 EN,
	input 										 CLK,
	input  [$clog2(DEPTH)-1:0] ADDR,
	output [WIDTH-1:0] 				 DO
);

	reg [WIDTH-1:0] rom [DEPTH];
	reg [$clog2(DEPTH)-1:0] addr_r;

	no_addr_x_p:
		assert property(@(posedge CLK) ~$isunknown(ADDR))
		else $fatal("Found X on ADDR!");
	no_clk_x_p:
		assert property(@(posedge CLK) ~$isunknown(CLK))
		else $fatal("Found X on ADDR!");

	// Port A
	always @(posedge CLK) begin
		if(EN) begin
			addr_r <= ADDR;
		end
	end

	assign DO = rom[addr_r];

endmodule

`endif