// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : sram_dp.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : SRAM dual-port verilog model, syncronous read
// ----------------------------------------------------------------------------

`ifndef INC_SRAM_DP_MODEL
`define INC_SRAM_DP_MODEL

module sram_dp 
#(
	parameter WIDTH = 32,
	parameter DEPTH = 10234
)
(
	// PORT A
	input 										 WEA,
	input 										 ENA,
	input 										 CLKA,
	input  [$clog2(DEPTH)-1:0] ADDRA,
	input  [WIDTH-1:0] 				 DIA, 
	output [WIDTH-1:0] 				 DOA,

	// PORT B
	input 										 WEB,
	input 										 ENB,
	input 										 CLKB,
	input  [$clog2(DEPTH)-1:0] ADDRB,
	input  [WIDTH-1:0] 				 DIB, 
	output [WIDTH-1:0] 				 DOB
);

	reg [WIDTH-1:0] ram[ DEPTH];
	reg [$clog2(DEPTH)-1:0] addra_r;
	reg [$clog2(DEPTH)-1:0] addrb_r;
	
	// Port A
	always @(posedge CLKA) begin
		if(ENA) begin
			if(WEA) ram[ADDRA] <= DIA;
			else addra_r <= ADDRA;
		end
	end
	
	assign DOA = ram[addra_r];

	// Port B
	always @(posedge CLKB) begin
		if(ENB) begin
			if(WEB) ram[ADDRB] <= DIB;
			else addrb_r <= ADDRB;
		end
	end
	
	assign DOB = ram[addrb_r];
	
endmodule

`endif