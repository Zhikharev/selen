module state_mashine (
             input rst,
			 input clk,
			 input [31:0] data,
			 input data_ready
           );
		   
	reg state_reg, state_next;
	reg [31:0] registre_file [4:0];
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_next <= 0;
			state_reg <= 0;
			registre_file[0] <= 32'h00000000; // status
			registre_file[1] <= 32'h00000000; // addr_first
			registre_file[2] <= 32'h00000000; // addr_end
			registre_file[3] <= 32'h00000000; // data
		end else begin
			state_reg <= state_next;
			if (state_next == state_start)	registre_file[0] <= registre_file[0] | 32'h00000001;
			if (state_next == state_finish)	registre_file[0] <= registre_file[0] | 32'h00000002;
			if (state_next == state_0)		registre_file[0] <= registre_file[0] & ~32'h00000004;
			
			if (state_next == state_addr_first)		begin
														registre_file[1] <= registre_file[1] | data;
														registre_file[0] <= registre_file[0] | 32'h00000004;
													end
			
			if (state_next == state_addr_end)		begin
														registre_file[2] <= registre_file[2] | data;
														registre_file[0] <= registre_file[0] | 32'h00000004;
													end
			
			if (state_next == state_data)			begin
														registre_file[3] <= registre_file[3] | data;
														registre_file[0] <= registre_file[0] | 32'h00000004;
													end
		end
	end
	
	localparam state_0 			= 0;
	localparam state_start 		= 1;
	localparam state_finish 	= 2;	
	localparam state_addr_first = 3;	
	localparam state_addr_end 	= 4;
	localparam state_data 		= 5;
	
	always @* begin
		case (state_reg)
			state_0			:	begin
									if (data == 32'h00000001) state_next <= state_start;
									if (data == 32'h00000002) state_next <= state_finish;
									
									if (data == 32'h00000003) state_next <= state_addr_first1;									
									if (data == 32'h00000004) state_next <= state_addr_end1;
									if (data == 32'h00000005) state_next <= state_data1;
								end
			state_start		:	state_next <= state_0;
			state_finish	: 	state_next <= state_0;
								
			state_addr_first:	state_next <= state_0;
								
			state_addr_end	:	state_next <= state_0;
								
			state_data1		:	state_next <= state_0;
								
			default: state_next <= state_0;
		endcase	
	end
		
endmodule
