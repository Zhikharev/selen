module reg_exe(
	input[31:0] srcaD,
	input [31:0] srcbD,
	input [4:0] rs1D,
	input [4:0] rs2D,
	input [4:0] rdD,
	input[31:0] pcD,//pc+4;
	input [19:0] imm20D,
	input [31:0] imm_or_adrD,
	input s_u_alu,
	input[3:0] alu_ctrl,
	input be_memD,
	input we_memD,
	input we_regD,
	input brch_typeD,
	input mux9D,
	input mux8D,
	input mux8_2D,
	input mux8_3D,
	input mux10D,
	input clk,
	input enbE,
	input flashD,
	input[1:0] cmdD

	output[31:0] srcaD_out,
	output [31:0] srcbD_out,
	output [4:0] rs1D_out,
	output [4:0] rs2D_out,
	output [4:0] rdD_out,
	output [31:0]pcD_out,//pc+4;
	output [19:0] imm20D_out,
	output s_u_alu_out,
	output[3:0] alu_ctrl_out,
	output be_memD_out,
	output we_memD_out,
	output we_regD_out,
	output brch_typeD_out,
	output mux9D_out,
	output mux8D_out,
	output mux8_2D_out,
	output mux8_3D_out,
	output mux10D_out,
	output imm_or_adr_out,
	output[1:0] cmdD_out
);
reg[31:0] srcaD_loc;
reg [31:0] srcbD_loc;
reg [4:0] rs1D_loc;
reg [4:0] rs2D_loc;
reg [4:0] rdD_loc;
reg [31:0] pcD_loc;//pc+4_loc;
reg [19:0] imm20D_loc;
reg s_u_alu_loc;
reg[3:0] alu_ctrl_loc;
reg be_memD_loc;
reg we_memD_loc;
reg we_regD_loc;
reg brch_typeD_loc;
reg mux9D_loc;
reg mux8D_loc;
reg mux8_2D_loc;
reg mux8_3D_loc;
reg mux5D_loc;
reg mux10D_loc;
reg[1:0] cmd_loc;
reg imm_or_adr_loc;
always @(posedge clk)
begin
	if(flashD) begin
		srcaD_loc <= 32'b0;
		srcbD_loc <= 32'b0;
		rs1D_loc <= 5'b0;
		rs2D_loc <= 5'b0;
		rdD_loc <= 5'b0;
		pcD_loc <= 32'b0;
		imm20D_loc <= 32'b0;
		s_u_alu_loc <= 1'b0;
		alu_ctrl_loc <= 4'b0;
		be_memD_loc <= 1'b0;
		we_memD_loc <= 1'b0;
		we_regD_loc <= 1'b0;
		brch_typeD_loc <= 1'b0;
		mux9D_loc <= 1'b0;
		mux8D_loc <= 1'b0;
		mux8_2D_loc <= 1'b0;
		mux8_3D_loc = 1'b0;
		mux10D_loc <= 1'b0;
		cmd_loc[1:0] <= 2'b00;
		imm_or_adr_loc <= 31'b0;
	end
	else begin
		if(enbD)begin
			srcaD_loc <= srcaD_loc;
			srcbD_loc <= srcbD_loc;
			rs1D_loc <= rs1D_loc;
			rs2D_loc <= rs2D_loc;
			rdD_loc <= rdD_loc;
			pcD_loc <= pcD_loc;
			imm20D_loc <= imm20D_loc;
			s_u_alu_loc <= s_u_alu_loc;
			alu_ctrl_loc <= alu_ctrl_loc;
			be_memD_loc <= be_memD_loc;
			we_memD_loc <= we_memD_loc;
			we_regD_loc <= we_regD_loc;
			brch_typeD_loc <= brch_typeD_loc;
			mux9D_loc <= mux9D_loc;
			mux8D_loc <= mux8D_loc;
			mux8_2D_loc <= mux8_2D_loc;
			mux8_3D_loc <= mux8_3D_loc;
			mux10D_loc <= mux10D_loc;
			cmd_loc <= cmd_loc;
			imm_or_adr_loc <= amm_or_adr_loc;
		end
		else begin
			srcaD_loc <= srcaD;
			srcbD_loc <= srcbD;
			rs1D_loc <= rs1D;
			rs2D_loc <= rs2D;
			rdD_loc <= rdD;
			pcD_loc <= pcD;
			imm20D_loc <= imm20D;
			s_u_alu_loc <= s_u_alu;
			alu_ctrl_loc <= alu_ctrl;
			be_memD_loc <= be_memD;
			we_memD_loc <= we_memD;
			we_regD_loc <= we_regD;
			brch_typeD_loc <= brch_typeD;
			mux9D_loc <= mux9D;
			mux8D_loc <= mux8D;
			mux8_2D_loc <= mux8_2D;
			mux8_3D_loc <= mux8_3D;
			mux10D_loc <= mux10D;
			cmdD_loc <= cmdD;
			imm_or_adr_loc <= imm_or_adr;
		end
	end
end

assign srcaD_out = srcaD_loc;
assign srcbD_out = srcbD_loc;
assign rs1D_out = rs1D_loc;
assign rs2D_out = rs2D_loc;
assign rdD_out = rdD_loc;
assign pcD_out = pcD_loc;
assign imm20D_out = imm20D_loc;
assign s_u_alu_out = s_u_alu_loc;
assign alu_ctrl_out = alu_ctrl_loc;
assign be_memD_out = be_memD_loc;
assign we_memD_out = we_memD_loc;
assign we_regD_out = we_regD_loc;
assign brch_typeD_out = brch_typeD_loc;
assign mux9D_out = mux9D_loc;
assign mux8D_out = mux8D_loc;
assign mux8_2D_out = mux8_2D_loc;
assign mux8_3D_out = mux8_3D_loc;
assign mux10D_out = mux10D_loc;
assign cmdD = cmdD_loc;
assign imm_or_adr_out = imm_or_adr_loc;
endmodule
