module reg_mem(
	input [31:0] resultM,
	input[31:0] srcbM,
	input[1:0] cndM,
	input[31:0] addrM,
	input[4:0] rdM,
	input be_memM,
	input we_memM,
	input be_regM,
	input we_regM,
	input brch_typeD,
	input mux9M,
	input clk,
	input enbM,
	input flashM,
	input [31:0] pcM,//pc+4
	input mux5M,

	output [31:0] resultM_out,
	output [31:0] srcbM_out,
	output[1:0] cndM_out,
	output[31:0] addrM_out,
	output[4:0] rdM_out,
	output be_memM_out,
	output we_memM_out,
	output be_regM_out,
	output we_regM_out,
	output brch_typeD_out,
	output mux9M_out,
	output [31:0] pcM_out,
	output mux5_out
);
reg [31:0] resultM_loc;
reg[1:0] cndM_loc;
reg[31:0] addrM_loc;
reg[4:0] rdM_loc;
reg be_memM_loc;
reg we_memM_loc;
reg be_regM_loc;
reg we_regM_loc;
reg brch_typeM_loc;
reg mux9M_loc;
reg[31:0] pcM_loc;
reg mux5_loc;
always @(posedge clk)
begin
	if(flashM) begin
		resultM_loc <= 32'b0;
		cndM_loc <= 2'b0;
		addrM_loc <= 32'b0;
		rdM_loc <= 1'b0;
		be_memM_loc <= 1'b0;
		we_memM_loc <= 1'b0;
		be_regM_loc <= 1'b0;
		we_regM_loc <= 1'b0;
		brch_typeM_loc <= 1'b0;
		mux9M_loc <= 1'b0;
		pcM_out <= 32'b0;
		mux5_loc <= 1'b0;
	end
	else begin
		if(enbM)begin
			resultM_loc <= resultM_loc;
			cndM_loc <= cndM_loc;
			addrM_loc <= addrM_loc;
			rdM_loc <= rdM_loc;
			be_memM_loc <= be_memM_loc;
			we_memM_loc <= we_memM_loc;
			be_regM_loc <= be_regM_loc;
			we_regM_loc <= we_regM_loc;
			brch_typeM_loc <= brch_typeM_loc;
			mux9M_loc <= mux9M_loc;
			pcM_loc <= pcM_loc;
			mux5_loc <= mux5_loc;
		end
		else begin
			resultM_loc <= resultM;
			cndM_loc <= cndM;
			addrM_loc <= addrM;
			rdM_loc <= rdM;
			be_memM_loc <= be_memM;
			we_memM_loc <= we_memM;
			be_regM_loc <= be_regM;
			we_regM_loc <= we_regM;
			brch_typeM_loc <= brch_typeD;
			mux9M_loc <= mux9M;
			pcM_loc <= pcM;
			mux5_loc <= mux5;
		end
	end
end
assign resultM_out = resultM_loc;
assign cndM_out = cndM_loc;
assign addrM_out = addrM_loc;
assign be_memM_out = be_memM_loc;
assign we_memM_out = we_memM_loc;
assign be_regM_out = be_regM_loc;
assign we_regM_out = we_regM_out;
assign brch_typeM_out = brch_typeM_loc;
assign mux9M_out = mux9M_loc;
assign mux5_out = mux5_loc;

endmodule
