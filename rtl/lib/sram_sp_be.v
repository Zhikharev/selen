// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sram_sp_be.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : SRAM single-port with byte-enable
//                  verilog model, syncronous read
// ----------------------------------------------------------------------------

`ifndef INC_SRAM_SP_BE_MODEL
`define INC_SRAM_SP_BE_MODEL

module sram_sp_be
#(
	parameter WIDTH = 32,
	parameter DEPTH = 10234
)
(
	input 										 WE,
	input [WIDTH/8-1:0]        WBE,
	input 										 EN,
	input 										 CLK,
	input  [$clog2(DEPTH)-1:0] ADDR,
	input  [WIDTH-1:0] 				 DI,
	output [WIDTH-1:0] 				 DO
);

	reg [WIDTH-1:0] ram [DEPTH];
	reg [$clog2(DEPTH)-1:0] addr_r;

	wire [WIDTH-1:0] mask_data;

	genvar i;
	generate
		for(i = 0; i < WIDTH/8; i = i + 1) begin
			assign mask_data[i*8+:8] = (WBE[i]) ? DI[i*8+:8] : ram[ADDR][i*8+:8]; 
		end
	endgenerate

	// Port A
	always @(posedge CLK) begin
		if(EN) begin
			if(WE) ram[ADDR] <= mask_data;
			addr_r <= ADDR;
		end
	end

	assign DO = ram[addr_r];

endmodule

`endif