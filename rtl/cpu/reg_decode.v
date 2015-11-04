module reg_fetch(
	input[31:0] instr_in,
	input [31:0] pc_in,//pc +4 
	input clk,
	input enb,
	input flash,
	output[31:0] instr_out,
	output [31:0] pc_out//pc +4
);
reg[31:0] instr_out_loc;
reg[31:0] pc_out_loc;
always @(posedge clk)
begin
	
	if(flash) begin
		instr_out_loc <= 32'b0;
		pc_out_loc <= 32'b0;
	end
	else begin
		if(enb)begin
			instr_out_loc <= instr_out_loc;
			pc_out_loc <= pc_out_loc;
		end
		else begin
			instr_out_loc <= instr_in;
			pc_out_loc <= pc_in;
		end
	end
end

assign instr_out = instr_out_loc;
assign pc_out = pc_out_loc;

endmodule
