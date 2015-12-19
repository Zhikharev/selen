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
	output[31:0] pc_next_out,
	input whait,
	output[31:0] inst,
	output stall,// fifo is empty 
	output pc_ctrl
);
///FSM for both fifo
localparam RST = 2'b00;
localparam RQST = 2'b01;
localparam WHT = 2'b10;
localparam WRT_RD = 2'b11; 
reg stb_loc;
reg cyc_loc;
reg wr_pc;
reg wr_inst;
reg full_pc;
reg full_inst;
reg empty_pc;
reg emrty_inst;
reg[1:0] state;
reg[1:0] state_next;
reg pc_whait;
always@(posedge clk)begin
	if(rst) state = RST;
	else state = state_next; 
end
always@* begin
	case(state)
	RST:begin
		stb_loc = 1'b0;
		cyc_loc = 1'b0;
		wr_pc = 1'b0;
		wr_inst = 1'b0;
		pc_whait = 1'b1;
		state_next = RQST;
	end
	RQST:begin
		stb_loc = 1'b1;
		cyc_loc = 1'b1;
		pc_whait = 1'b0;
		wr_pc = 1'b1;
		state_next = WHT;
	end
	WHT:begin
		if((wb_stall||full_pc||full_inst)&&(~ack))begin
			stb_loc = 1'b0;
			pc_whait = 1'b1;
			state_next = WHT;
			wr_pc = 1'b0;
		end
		if(ack)begin
			wr_inst = 1'b1;		
		end
		state_next = WHT;
	end
	WRT_RD:begin
		
	end
	endcase
end
cpu_fifo #(10,32) pc_fifo(
	.clk(clk),
	.wr_en(wr_pc),
	.din(pc_next_in),
	.rst(~brnch),
	
	.rd_en(~whait),
	.dout(pc_next_out),
	
	.empty(empty_pc),
	.full(full_pc)
);
cpu_fifo #(10,32) inst_fifo(
	.clk(clk),
	.wr_en(wr_inst),
	.din(wb_inst),
	.rst(~brnch),

	.rd_en(~whait),
	.dout(inst),

	.empty(empty_inst),
	.full(full_inst)
);
assign stb = stb_loc;
assign cyc = cyc_loc;
assign wb_addr = pc;
assign stall = empty_inst;// fifo is empty 
assign pc_ctrl = pc_whait;
 
endmodule
