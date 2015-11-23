
module fifo
#(
	parameter DEPTH = 2,
	parameter SIZE	= 8
)
(
	input clk,
	input wr_en,
	input [SIZE-1:0] din,
	
	input rd_en,
	output reg [SIZE-1:0] dout,
	
	output empty,
	output full
);
	
	reg [SIZE-1:0] ram [(1 << DEPTH) - 1:0];
	reg [DEPTH:0] rd_pointer = 0;
	reg [DEPTH:0] wr_pointer = 0;

	assign empty = (wr_pointer-rd_pointer == 0) ? 1'b1 : 1'b0;
	assign full  = (wr_pointer-rd_pointer == (1 << DEPTH)) ? 1'b1 : 1'b0;

	
	always @(posedge clk) begin
		case ({wr_en,rd_en})
			2'b01:	if (wr_pointer-rd_pointer != 0) begin
						dout <= ram[rd_pointer];
						rd_pointer <= rd_pointer + 1;
					end
			2'b10:	if (wr_pointer-rd_pointer != (1 << DEPTH)) begin
						ram[wr_pointer] <= din;
						wr_pointer <= wr_pointer + 1'b1;
					end
			2'b11:	begin
						if (wr_pointer-rd_pointer != (1 << DEPTH)) begin
							ram[wr_pointer] = din;
							wr_pointer = wr_pointer + 1'b1;
						end
						if (wr_pointer-rd_pointer != 0) begin
							dout = ram[rd_pointer];
							rd_pointer = rd_pointer + 1;
						end						
					end
			default:;
		endcase
	end
	
endmodule
