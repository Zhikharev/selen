include core_defines.vh;
module alu_test(
	);

reg[31:0] src1_loc;
reg[31:0]	src2_loc;
reg[3:0] 	cmd_loc;
reg[2:0]	cnd_loc;
wire[31:0] result;
wire 				brnch;

core_alu alu (
.src1(src1_loc),
.src2(src2_loc),
.alu_op(cmd_loc),
.brnch_cnd(cnd_loc),
.alu_result(result),
.brnch_takenn(brnch)			
);

initial begin
	src2_loc = 13;
	src1_loc = 11;
	cnd_loc[2] = 1'b0;
	#5;
	cmd_loc = `ADD_ALU;
	#5;
	cmd_loc = `SUB_ALU;
	#5;
	cmd_loc = `AND_ALU;
	#5;
	cmd_loc = `AM_ALU;
	#5;
	src2_loc = -13;
	src1_loc = 11;
	#5;
	cmd_loc = `ADD_ALU;
	#5;
	cmd_loc = `SUB_ALU;
	#5;
	cmd_loc = `AM_ALU;
	#5;
	src2_loc = 13;
	src1_loc = -11;
	#5;
	cmd_loc = `SUB_ALU;
	#5;
	cmd_loc = `AM_ALU;
end
endmodule
