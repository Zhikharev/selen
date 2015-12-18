module fsm(
	input fifo_pc_full,
	input fifo_st_full,
	input fifo_inst_full,
	input lw,
	input sw,
	input whait,
	input inst_ack_in,
	input data_ack_in,
	output sall_cpu,
	output we_fifo_pc,
	output we_fifo_st,
	output we_fifo_inst,
	output inst_stb,
	output inst_cyc,
	output data_stb
	input clk,
	input rst,
	output pc_ctrl
);
localparam state0 = 2'b00;
localparam state1 = 2'b01;
localparam state2 = 2'b10;
localparam state3 = 2'b11;
reg[1:0] state_lw;
reg[1:0] state_lw_next;
//mem load fsm 
always@(posedge clk)begin
	if(rst) state_ld <= state0;
	else state <= state_ld_next;
end
always @* begin
	case(state_ld) 
		sate0:begin
			if(lw)begin
				d_stb = 1'b1;
				state_ld_next = state1;
				stall = 1'b1;
			end
			else begin
				d_stb = d_stb;
				state_ld_next = state0;
				stall = 1'b0;
			end
		end
		state1:begin
			if(data_ack_in)begin
				d_stb = 1'b0;
				stall = 1'b0;
				state_ld_next = state0;
			end
			else begin
				d_stb = 1'b1;
				stall = 1'b1;
				state_ld_next = state1;
			end
		end
	default begin

	end
	endcase
end
//fsm for st mem 
always@* begin
	if(sw)begin
		d_stb = 1'b1;
	end
end
//fsm for pc_next
reg[1:0] state_pc;
reg[1:0] sate_pc_next;
always @(posedge clk)begin
	if(rst) state_pc = state0;
	else state_pc = state_pc_next;
end
always@* begin
	case(state_pc)
	state0 begin
		we_pc = 1'b1;
		state_pc_next = state1;
	end
	state1:begin
		if(fifo_pc_full)begin
			we_pc = 1'b0;
			pc_ctrl = 1'b1;
			state_next_pc = state3;
		end
		else begin
			state_pc_next = state1;
		end
	end
	state3:begin
		if(fifo_pc_full)begin
			satate_pc_next = state1;
		end
		else begin
			pc_ctrl = 1'b0;
			we_pc = 1'b1;
			state_next_pc = state1;
		end
	end
	endcase
end
///fsm for instractions
reg[1:0] state_inst;
reg[1:0] state_next_inst;
always@(posedge clk)begin
	if(rst) state_inst <= 1'b0;
	else state_inst <= state_next_inst;
end
always @* begin
	case(sate_inst)
	state0:begin
		stb_inst = 1'b1;
		sate_next_inst = state1;
	end
	state1:begin
		if(fifo_inst_full)begin
			stb_inst =1'b0;
			sate_next_pc = state2;
		end
		else begin
			stata_next_pc = state1;
		end
		if(inst_stall)begin
			stb_inst =1'b0;
			pc_ctrl = 1'b1;
			state_next_inst = state3;
		end
		else begin
			state_next_inst = state1;
		end
	end
	state2:begin
		if(fifo_inst_full)begin
			state_next_pc = state2;
		end
		else begin
			state_next_pc = state1;
		end
	end
	endcase
end
endmodule
