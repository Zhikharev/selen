module fifo(
	input [31:0] data_in,
	output [31:0] data_out,
	input rst,
	input clk,
	output full,
	output empty,
	input wrt_enb,
	input rd_enb
);
reg[3:0] wrt_pointer;
reg[3:0] rd_pointer;
reg[31:0] data_loc [0:15];
reg [31:0] data_out_loc;
reg full_loc;
reg empty_loc;
always@(posedge clk)
begin
	if(rst)begin
		wrt_pointer <= 4'b0;
		rd_pointer <= 4'b0;
	end
	else begin
		if(wrt_enb)begin
			data_loc[wrt_pointer] <= data_in;
			wrt_pointer = wrt_pointer +1 ;
			if(wrt_pointer == 4'b1111)begin
				full_loc <= 1'b1;
			end
			else begin
				full_loc <= 1'b0;
			end
			if(wrt_pointer == 4'b0)begin
				empty_loc <= 1'b1;
			end
			else begin
				empty_loc <= 1'b0;
			end
		end
		if(rd_enb)begin
			data_out_loc <= data_loc[rd_pointer];
			rd_pointer <= rd_pointer +1;
		end
	end
	
end
assign full = full_loc;
assign empty = empty_loc;
assign data_out = data_out_loc;
endmodule
