// ----------------------------------------------------------------------------
// FILE NAME            	:core_csr.sv
// PROJECT                	:Selen
// AUTHOR                	:
// AUTHOR'S EMAIL 		:
// ----------------------------------------------------------------------------
// DESCRIPTION        	:
// ----------------------------------------------------------------------------
  module core_csr
 	(
 		input clk,
 		input	rst_n,
 		output [31:0] ncache_base,
 		output [31:0] ncache_mask
 	);
 
 	reg [32:0] ncache_base_r;
 	reg [32:0] ncache_mask_r;
 
 	always @(posedge clk or negedge rst_n) begin
 		if(~rst_n) begin
 			ncache_base_r <= `NCACHE_BASE_ADDR;
 			ncache_mask_r <= `NCACHE_MASK_ADDR;
 		end
 	end
 
 	assign ncache_base = ncache_base_r;
 	assign ncache_mask = ncache_mask_r;
 
 	// WDT
 	reg [`TIMER_BITWISE-1:0] counter_r;
 
 	always @(posedge clk, negedge rst_n) begin
 		if(~rst_n) counter_r <= 0;
 		else counter_r <= counter_r + 1'b1;
 	end
 
 endmodule
 
