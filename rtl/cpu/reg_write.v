module reg_write(
	input be_regW,
	input we_regW,
	input mux9W,
	input[31:0] resultW,
	input[4:0] rdW,
	input[31:0] memW,
	input [31:0] pc,////pc+4
	input mux5,
	input clk,
	input flashW,
	input enbW,
	output be_regW_out,
	output we_regW_out,
	output mux9W_out,
	output[31:0] resultW_out,
	output[4:0] rdW_out,
	output[31:0] memW_out,
	output [31:0] pc_out,
	output mux5_out
);
reg be_regW_loc;
reg we_regW_loc;
reg mux9W_loc;
reg[31:0] resultW_loc;
reg [4:0]rdW_loc;
reg[31:0] memW_loc;
reg[31:0] pc_loc;
reg mux5_loc;
always @(posedge clk)
begin
	if(flashW)begin
		be_regW_loc <= 1'b0;
		we_regW_loc <= 1'b0;
		mux9W_loc <= 1'b0;
		resultW_loc <= 32'b0;
		rdW_loc <= 5'b0;
		memW_loc <= 32'b0;
		mux5_loc <= 1'b0;
		pc_loc <= 32'b0;
	end
	else begin
		if(enbW)begin
			be_regW_loc <= be_regW_loc;
			we_regW_loc <= we_regW_loc;
			mux9W_loc <= mux9W_loc;
			resultW_loc <= resultW_loc;
			rdW_loc <= rdW_loc;
			memW_loc <= memW_loc;
			pc_loc <= pc_loc;
			mux5_loc <= mux5_loc;
		end
		else begin
			be_regW_loc <= be_regW;
			we_regW_loc <= we_regW;
			mux9W_loc <= mux9W;
			resultW_loc <= resultW;
			rdW_loc <= rdW;
			memW_loc <= memW;
			pc_loc <= pc;
			mux5_loc <= mux5;
		end
	end
end
assign be_regW_out = be_regW;
assign we_regW_out = we_regW;
assign mux9W_out = mux9W;
assign resultW_out = resultW_loc;
assign memW_out = memW_loc;
assign rdW_out = rdW;
assign mux5_out = mux5_loc;
assign pc_out = pc_loc;
endmodule
