// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : fifo.v
// PROJECT        : Selen
// AUTHOR         : Sokolovskii Artem
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : FIFO
// ----------------------------------------------------------------------------

module cpu_fifo
#(
	parameter DEPTH = 2,
	parameter SIZE = 8
)
(
	input clk,
	input wr_en,
	input [SIZE-1:0] din,
	input rst,
	
	input rd_en,
	output reg [SIZE-1:0] dout,
	
	output empty,
	output full
);
	localparam READ 		= 2'b01;
	localparam WRITE		= 2'b10;
	localparam READ_WRITE 	= 2'b11;
	
	reg [SIZE-1:0] ram [(1 << DEPTH) - 1:0];
	reg [DEPTH - 1:0] rd_pointer ;
	reg [DEPTH - 1:0] wr_pointer ;
	
	reg [DEPTH - 1:0] rd_pointer_r ;
	reg [DEPTH - 1:0] wr_pointer_r ;

	assign empty = (wr_en) ? 1'b0 : ((wr_pointer-rd_pointer == 0) ? 1'b1 : 1'b0);
	assign full  = (wr_pointer-rd_pointer == (1 << DEPTH) - 1) ? 1'b1 : 1'b0;
	
	
always @(posedge clk) begin
	if(rst)begin
		rd_pointer <= 0;
		rd_pointer_r <= 0;
		wr_pointer <= 0;
		wr_pointer_r <= 0;
	end
	else begin
		case ({wr_en,rd_en})
			READ:		if (~empty) begin
							rd_pointer <= rd_pointer_r;
							dout <= ram[rd_pointer_r];						
							rd_pointer_r <= rd_pointer_r + 1'b1;
						end
			WRITE:		if (~full) begin
							wr_pointer <= wr_pointer_r;
							ram[wr_pointer_r] <= din;
							wr_pointer_r <= wr_pointer_r + 1'b1;
						end
			READ_WRITE:	begin
							if (~full) begin
								wr_pointer <= wr_pointer_r;
								ram[wr_pointer_r] = din;							
								wr_pointer_r = wr_pointer_r + 1'b1;
							end
							if (~empty) begin
								rd_pointer <= rd_pointer_r;
								dout = ram[rd_pointer_r];							
								rd_pointer_r = rd_pointer_r + 1;
							end						
						end
			default:;
		endcase
	end
end
endmodule
