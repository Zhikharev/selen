module state_mashine (
			 input clk,
			 input rst,
			 input dready,
			 input  [31:0] din,
			 output [31:0] data,
			 output [31:0] status_reg,
			 output [31:0] addr_first_reg,
			 output [31:0] addr_end_reg
           );
		   
	reg [3:0] state_reg, state_next;
	reg [31:0] registre_file [4:0];
	
	assign status_reg		= registre_file[0];
	assign addr_first_reg	= registre_file[1];
	assign addr_end_reg		= registre_file[2];
	assign data 			= registre_file[3];
	
	localparam state_0 			= 0;
	localparam state_start 		= 1;
	localparam state_finish 	= 2;	
	localparam state_addr_first = 3;	
	localparam state_addr_end 	= 4;
	localparam state_data 		= 5;
	
	localparam state_addr_first1 = 6;	
	localparam state_addr_end1 	 = 7;
	localparam state_data1 		 = 8;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_next <= 0;
			state_reg <= 0;
			registre_file[0] <= 32'h00000000; // status
			registre_file[1] <= 32'h00000000; // addr_first
			registre_file[2] <= 32'h00000000; // addr_end
			registre_file[3] <= 32'h00000000; // data
		end else begin
			
			if (state_next == state_start)	registre_file[0] <= registre_file[0] | 32'h00000001;
			if (state_next == state_finish)	registre_file[0] <= registre_file[0] | 32'h00000002;
			if (state_next == state_0)		registre_file[0] <= registre_file[0] & ~32'h00000004;
			
			if ((state_reg == state_addr_first1)  & (dready)) begin
														registre_file[1] <= din;
														//registre_file[0] <= registre_file[0] | 32'h00000004;
													end
			
			if ((state_reg == state_addr_end1) & (state_next == state_0)) begin
														registre_file[2] <= din;
														//registre_file[0] <= registre_file[0] | 32'h00000004;
													end
			
			if ((state_reg == state_data1) & (state_next == state_0)) begin
														registre_file[3] <= din;
														registre_file[0] <= registre_file[0] | 32'h00000004;
													end
			
			state_reg <= state_next;
		end
	end
	
	always @* begin
		case (state_reg)
			state_0			: if (dready)	begin
								if (din == 32'h00000001) state_next <= state_start;
								if (din == 32'h00000002) state_next <= state_finish;
								
								if (din == 32'h00000003) state_next <= state_addr_first;									
								if (din == 32'h00000004) state_next <= state_addr_end;
								if (din == 32'h00000005) state_next <= state_data;
							 end
			state_start		 :	state_next <= state_0;
			state_finish	 : 	state_next <= state_0;
								
			state_addr_first :	if (dready)	state_next <= state_addr_first1;
			state_addr_first1:	state_next <= state_0;
								
			state_addr_end	 :	if (dready)	state_next <= state_addr_end1;
			state_addr_end1	 :	state_next <= state_0;
								
			state_data		 :	if (dready)	state_next <= state_data1;								
			state_data1		 :	state_next <= state_0;
								
			default: state_next <= state_0;
		endcase	
	end
		
endmodule
