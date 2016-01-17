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
	input 										 WE,
	input 										 EN,
	input 										 CLK,
	input  [$clog2(DEPTH)-1:0] ADDR,
	input  [WIDTH-1:0] 				 DI, 
	output [WIDTH-1:0] 				 DO
);

	reg [WIDTH-1:0] ram[ DEPTH];
	reg [$clog2(DEPTH)-1:0] addr_r;
	
	// Port A
	always @(posedge CLK) begin
		if(EN) begin
			if(WE) ram[ADDR] <= DI;
			else addr_r <= ADDR;
		end
	end
	
	assign DO = ram[addr_r];

endmodule

`endif