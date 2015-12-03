module mem_block(
	input clk,
	input rst,
	input mux1,
	input mux2,
	input mux3,
	input mux4,
	input mux4_2,
	output stb,
	input akn_in,
	output cyc,
	output[31:0] inst,
	input[31:0] reg_in,
	input[31:0] imm12_in,
	input[31:0] imm20_in,
	input stall_in,
	output pc_stop,
	input[31:0]addr_in
);
reg[31:0] pc;
always@(posedge clk)
begin
	if(rst)begin
		pc <= 31'b0;
	end
	else begin
		if(mux2)begin
			pc <= pc;
		end
		else begin
			if(mux3)begin
				pc <= imm20_in;
			end
			else begin
				if(mux1)begin
					if((mux4_2)&&(mux4))begin
						pc <= pc +4;
					end
					if((~mux4_2)&&(mux4))begin
						pc <= pc + inst;
					end
					if((mux4_2)&&(~mux4))begin
						pc <= pc + imm12_in;
					end
					if((~mux4_2)&&(~mux4))begin
						pc <= imm12_in + reg_in;
					end
				end
				else begin
					pc<=addr_in;
				end
			end
		end
	end
end
mem_ctrl mem_ctrl (
	.akn_in(akn_in),
	.cyc_out(cyc),
	.stb_out(stb),
	.full(fifo2mem_full),
	.empty(fifo2mem_empty),
	.rd_enb(mem2fifo_rd_enb),
	.wrt_enb(mem2fifo_wrt_enb),
	.rst(rst),
	.clk(clk),
	.stall_in(stall_in),
	.pc_stop(pc_stop)
);
wire fifo2mem_full;
wire fifo2mem_empty;
wire mem2fifo_rd_enb;
wire mem2fifo_wrt_enb;
fifo fifo(
	.data_in(pc),
	.data_out(inst),
	.rst(rst),
	.clk(clk),
	.full(fifo2mem_full),
	.empty(fifo2mem_empty),
	.wrt_enb(mem2fifo_wrt_enb),
	.rd_enb(mem2fifo_rd_enb),
	.stall_in(stall_in) 
);

endmodule

