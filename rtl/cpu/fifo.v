module fifo(
	input [31:0] data_in,
	output [31:0] data_out,
	input rst,
	input clk,
	output full,
	output empty,
	input wrt_enb,
	input rd_enb,
	input stall_in 
);
reg[3:0] wrt_pntr;
reg[3:0] rd_pntr;
reg[31:0] data [0:15];
reg[31:0] data_out_loc;
always@(posedge clk)
begin
	if(rst)begin
		wrt_pntr <=4'b0;
		rd_pntr <= 4'b0;
	end
	else begin
		if(wrt_enb)begin
			wrt_pntr <= wrt_pntr +1;
		end
		else begin
			wrt_pntr <= wrt_pntr;
		end
		if(rd_enb)begin
			rd_pntr <= rd_pntr +1;
		end
		else begin
			rd_pntr <= rd_pntr;
		end
	end
end
always@(posedge clk)
begin
	if(rst)begin
	end
	else begin
		if(wrt_enb)begin
			data[wrt_pntr] <= data_in;
		end
		if(rd_enb)begin
			data_out_loc <= data[rd_pntr];
		end
	end
end
assign data_out = data_out_loc;
assign full = (wrt_pntr == 4'b1111)? 1'b1: 1'b0;
assign empty = (rd_pntr == 4'b1111)? 1'b1:1'b0;
endmodule
