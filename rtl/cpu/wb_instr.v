module wd_inst (
	//wb interface
	output stb,
	output cyc,
	output[31:0] wb_addr,
	input wb_stall,
	input ack,
	input[31:0] wb_inst,
	input rst,
	input clk,

	//terminals form cpu

	input brnch,
	input[31:0] pc,
	input[31:0] pc_next_in,
	input[31:0] pc_next_out,
	input whait,
	output[31:0] inst,
	output stall,
	output pc_whait
);
localparam RST = 3'b0;
localparam RQST = 3'b001;
localparam WHT = 3'b010;
localparam STALL = 3'b011;
localparam BRCH = 3'b100;
localparam FULL_INST = 3'b101;
localparam FULL_PC = 3'b110;
reg[2:0] state;
reg[2:0] state_next;
reg wr_pc;
reg wr_inst;
reg stb_loc;
reg cyc_loc;
reg rst_fifo;
reg pc_ctr
always@(posedge clk)begin
	if(rst)state <= 3'b000;
	else state <= state_next;
end
always @*begin
	case(state)
		RST:begin
			stb_loc = 1'b0;
			cyc_loc = 1'b0;
			rst_fifo = 1'b1;
			state_next = RQST;
		end
		RQST:begin
			stb_loc = 1'b1;
			cyc_loc = 1'b1;
			rst_fifo = 1'b0;
			state_next = WHT;
		end
		WHT:begin
			if(wb_stall)begin
				stb_loc = 1'b0;
				state_next = STALL;
				pc_ctrl = 1'b1;
			end
			if(full_inst)begin
				stb_loc = 1'b0;
				wr_inst = 1'b0;
				state_next = FULL_INST;
				pc_ctrl = 1'b1;
			end
			if(full_pc)begin
				stb_loc = 1'b0;
				wr_pc = 1'b0;
				state_next = FULL_PC;
				pc_ctrl = 1'b1;
			end
			if(brch)begin
				stb_loc = 1'b0;
				state_next = BRCH;
				pc_ctrl = 1'b1;
			end
		end
		BRCH:begin
			state_next = RST;
		end
		STALL:begin
			if(wb_stall) state_next = STALL;
			else state_next = WHT;
		end
		FULL_INST:begin
			if(full_inst) state_next = FULL_INST;
			else state_next = WHT;
		end
		FULL_PC:begin
			if(full_pc) state_next = FULL_PC;
			else state_next = WHT;
		end
	endcase
end
cpu_fifo pc_fifo(
#(
	DEPTH = 10,
	SIZE = 32
)
	clk(clk),
	wr_en(wr_pc),
	din(pc_next),
	rst(rst_fifo),
	
	rd_en(~whait),
	dout(pc_next_out),
	
	empty(empty_pc),
	full(full_pc)
);
cpu_fifo inst_fifo(
#(
	DEPTH = 10,
	SIZE = 32
)
	clk(clk),
	wr_en(wr_inst),
	din(wb_inst),
	rst(rst_fifo),

	rd_en(~whait),
	dout(inst),

	empty(empty_inst),
	full(full_inst)
);
endmodule
