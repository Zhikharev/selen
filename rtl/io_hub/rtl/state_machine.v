// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : state_machine.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : get data
// ----------------------------------------------------------------------------

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
	
	localparam STATE_IDLE 			= 0;
	localparam STATE_START 		= 1;
	localparam STATE_FINISH 	= 2;	
	localparam STATE_ADDR_FIRST = 3;	
	localparam STATE_ADDR_END 	= 4;
	localparam STATE_DATA 		= 5;
	
	localparam STATE_ADDR_FIRST1 = 6;	
	localparam STATE_ADDR_END1 	 = 7;
	localparam STATE_DATA1 		 = 8;
	
	localparam 	START_BIT		 = 32'h00000001;
	localparam 	FINISH_BIT		 = 32'h00000002;
	localparam 	DREADY_BIT		 = 32'h00000004;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_next <= 0;
			state_reg <= 0;
			registre_file[0] <= 32'h00000000; // status
			registre_file[1] <= 32'h00000000; // addr_first
			registre_file[2] <= 32'h00000000; // addr_end
			registre_file[3] <= 32'h00000000; // data
		end else begin
			
			if (state_next == STATE_START)	registre_file[0] <= registre_file[0] | START_BIT;
			if (state_next == STATE_FINISH)	registre_file[0] <= registre_file[0] | FINISH_BIT;
			if (state_next == STATE_IDLE)		registre_file[0] <= registre_file[0] & ~DREADY_BIT;
			
			if ((state_reg == STATE_ADDR_FIRST1)  & (dready)) begin
														registre_file[1] <= din;
													end
			
			if ((state_reg == STATE_ADDR_END1) & (state_next == STATE_IDLE)) begin
														registre_file[2] <= din;
													end
			
			if ((state_reg == STATE_DATA1) & (state_next == STATE_IDLE)) begin
														registre_file[3] <= din;
														registre_file[0] <= registre_file[0] | DREADY_BIT;
													end
			
			state_reg <= state_next;
		end
	end
	
	always @* begin
		case (state_reg)
			STATE_IDLE			: if (dready)	begin
								if (din == 32'h00000001) state_next <= STATE_START;
								if (din == 32'h00000002) state_next <= STATE_FINISH;
								
								if (din == 32'h00000003) state_next <= STATE_ADDR_FIRST;									
								if (din == 32'h00000004) state_next <= STATE_ADDR_END;
								if (din == 32'h00000005) state_next <= STATE_DATA;
							 end
			STATE_START		 :	state_next <= STATE_IDLE;
			STATE_FINISH	 : 	state_next <= STATE_IDLE;
								
			STATE_ADDR_FIRST :	if (dready)	state_next <= STATE_ADDR_FIRST1;
			STATE_ADDR_FIRST1:	state_next <= STATE_IDLE;
								
			STATE_ADDR_END	 :	if (dready)	state_next <= STATE_ADDR_END1;
			STATE_ADDR_END1	 :	state_next <= STATE_IDLE;
								
			STATE_DATA		 :	if (dready)	state_next <= STATE_DATA1;								
			STATE_DATA1		 :	state_next <= STATE_IDLE;
								
			default: state_next <= STATE_IDLE;
		endcase	
	end
		
endmodule
