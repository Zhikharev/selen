// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sram_sp.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : SRAM single-port verilog model, syncronous read
// ----------------------------------------------------------------------------

`ifndef INC_SRAM_SP_MODEL
`define INC_SRAM_SP_MODEL

module sram_sp
#(
	parameter WIDTH = 32,
	parameter DEPTH = 10234
)
(

	input 											clka,
	input 											ena,
	input 											wea,
	input  [$clog2(DEPTH)-1:0] 	addra,
	input  [WIDTH-1:0] 					dina,
	output [WIDTH-1:0]          douta
);

	reg [WIDTH-1:0] ram [0:DEPTH-1];
	reg [$clog2(DEPTH)-1:0] addr_r;

	// Port A
	always @(posedge clka) begin
		if(ena) begin
			if(wea) ram[addra] <= dina;
			addr_r <= addra;
		end
	end

	assign douta = ram[addr_r];

endmodule

`endif