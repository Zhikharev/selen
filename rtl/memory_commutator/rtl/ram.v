// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : ram.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

module ram(
	input sys_clk,
	
	// RAM port1 instructions
	input		    		ram_stb_i,
	output 		 			ram_ack_o,
	input	 [15:0]			ram_addr_i,
	output 	 [31:0] 		ram_data_o,
	
	// RAM port2 data
	input		   			ram2_stb_i,
	output 		 			ram2_ack_o,
	input	 				ram2_we_i,
	input	 [15:0]			ram2_addr_i,
	input	 [31:0]	  		ram2_data_i,
	output 	 [31:0] 		ram2_data_o
);
	reg 	 [31:0] 		ram [512:0];
	
	reg 	 [31:0] 		data_o;	
	reg 					ack_o;
	
	reg 	 [31:0] 		data2_o;
	reg 					ack2_o;
		
	// RAM port1	
	always @(posedge sys_clk)
	begin
		if (ram_stb_i) begin
			data_o <= ram[ram_addr_i];
			ack_o <= ram_stb_i;
		end
	end
	
	assign ram_data_o = data_o;
	assign ram_ack_o  = ack_o;
	
	// RAM port2
	always @(posedge sys_clk)
	begin
		if (ram2_we_i & ram_stb_i) begin
			ram[ram2_addr_i] <= ram2_data_i;
		end else begin
			data2_o <= ram[ram2_addr_i];
			ack2_o <= ram2_stb_i;
		end
	end
	
	assign ram2_data_o = data2_o;
	assign ram2_ack_o  = ack2_o;
endmodule
