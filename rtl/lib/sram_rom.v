// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sram_rom.v
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
	input 											clka,
	input 											ena,
	input  [$clog2(DEPTH)-1:0] 	addra,
	output [WIDTH-1:0]          douta
);

	reg [WIDTH-1:0] rom [DEPTH];
	reg [$clog2(DEPTH)-1:0] addr_r;

	// Port A
	always @(posedge clka) begin
		if(ena) begin
			addr_r <= addra;
		end
	end

	assign douta = rom[addr_r];

endmodule

`endif