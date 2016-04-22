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
	input 											clka,
	input 											ena,
	input 											wea,
	input  [$clog2(DEPTH)-1:0] 	addra,
	input  [WIDTH-1:0] 					dina,
	output [WIDTH-1:0]          douta,

	// PORT B
	input 											clkb,
	input 											enb,
	input 											web,
	input  [$clog2(DEPTH)-1:0] 	addrb,
	input  [WIDTH-1:0] 					dinb,
	output [WIDTH-1:0]          doutb
);

	reg [WIDTH-1:0] ram [0:DEPTH-1];
	reg [$clog2(DEPTH)-1:0] addra_r;
	reg [$clog2(DEPTH)-1:0] addrb_r;

	// Port A
	always @(posedge clka) begin
		if(ena) begin
			if(wea) ram[addra] <= dina;
			else addra_r <= addra;
		end
	end

	assign douta = ram[addra_r];

	// Port B
	always @(posedge clkb) begin
		if(enb) begin
			if(web) ram[addrb] <= dinb;
			else addrb_r <= addrb;
		end
	end

	assign doutb = ram[addrb_r];

endmodule

`endif