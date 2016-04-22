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
	input 											clka,
	input 											ena,
	input  [WIDTH/8-1:0]				wea,
	input  [$clog2(DEPTH)-1:0] 	addra,
	input  [WIDTH-1:0] 					dina,
	output [WIDTH-1:0]          douta
);

	reg [WIDTH-1:0] ram [0:DEPTH-1];
	reg [$clog2(DEPTH)-1:0] addr_r;

	wire [WIDTH-1:0] mask_data;

	genvar i;
	generate
		for(i = 0; i < WIDTH/8; i = i + 1) begin
			assign mask_data[i*8+:8] = (wea[i]) ? dina[i*8+:8] : ram[addra][i*8+:8];
		end
	endgenerate

	// Port A
	always @(posedge clka) begin
		if(ena) begin
			ram[addra] <= mask_data;
			addr_r <= addra;
		end
	end

	assign douta = ram[addr_r];

endmodule

`endif