module sim_RAM;
 	reg sys_clk;
	
	// RAM port1 instructions
	reg		        ram_stb_i;
	wire 		 	ram_ack_o;
	reg	 			ram_we_i;
	reg	 	 [15:0]	ram_addr_i;
	reg	 	 [31:0] ram_data_i;
	wire 	 [31:0] ram_data_o;
	
	// RAM port2 data
	reg	   	  	    ram2_stb_i;
	wire 		    ram2_ack_o;
	reg	  	        ram2_we_i;
	reg	 	 [15:0]	ram2_addr_i;
	reg	 	 [31:0] ram2_data_i;
	wire 	 [31:0] ram2_data_o;
	
	RAM dut(
		sys_clk,

		// RAM port1 instructions
		ram_stb_i,
		ram_ack_o,
		ram_we_i,
		ram_addr_i,
		ram_data_i,
		ram_data_o,

		// RAM port2 data
		ram2_stb_i,
		ram2_ack_o,
		ram2_we_i,
		ram2_addr_i,
		ram2_data_i,
		ram2_data_o
	);
	
	initial begin
		sys_clk 	= 1'b1;
		ram_stb_i	= 1'b1;
		ram_we_i	= 1'b1;
		ram_addr_i	= 16'h20;
		ram_data_i 	= 32'hAAAA;
		
/*		# 100 sys_clk 	= 1'b0;
		# 100 sys_clk 	= 1'b1;*/
		
		ram2_stb_i	= 1'b1;
		ram2_we_i	= 1'b0;
		ram2_addr_i	= 16'h20;

		# 100 sys_clk 	= 1'b0;
		# 100 sys_clk 	= 1'b1;
/*		# 100 sys_clk 	= 1'b0;
		# 100 sys_clk 	= 1'b1;*/
		
		
	end
endmodule
