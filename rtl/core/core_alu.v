// ----------------------------------------------------------------------------
// FILE NAME            	: core_csr.sv
// PROJECT                : Selen
// AUTHOR                 :	Alexandr Bolotnikov	
// AUTHOR'S EMAIL 				:	AlexsanrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		:	ALU
// ------------------------------------------
include core_defines.vh;
module 	core_alu (
	input signed[31:0]	 				src1,
	input signed[31:0]					src2,
	input[3:0]									alu_op,
	input[2:0]									brnch_cnd,
	output reg  signed[31:0]		alu_result,
	output reg									brnch_takenn			
);
reg[3:0] alu_op_loc;
reg[1:0] brnch_control_loc;
//assign alu_op_loc = (brnch_cnd[2])?brnch_control_loc:alu_op;
//brnch_control
always@* begin
		brnch_takenn = 1'b0;
		if(brnch_cnd[2])begin
			alu_op_loc = brnch_control_loc;
		end 
		else alu_op_loc = alu_op; 
		case(brnch_cnd)
			`ALU_BEQ: begin
				brnch_control_loc = `SUB_ALU;
				if(alu_result == 0) begin
					brnch_takenn = 1'b1;
				end
			end	
			//	
			`ALU_BNE: begin
				brnch_control_loc = `SUB_ALU;
				if(alu_result != 0) begin
					brnch_takenn = 1'b1;
				end
			end
			//
			`ALU_BLT: begin
				brnch_control_loc = `SLT_ALU;
				if(alu_result) brnch_takenn = 1'b1;
			end
			//
			`ALU_BLTU: begin
				alu_op_loc = `SLTU_ALU;
				if(alu_result) brnch_takenn = 1'b1;
			end
		endcase // brnch_cnd	
end
//general alu
always @* begin  
	case(alu_op_loc)
		`ADD_ALU: alu_result = src1 + src2;
		`AND_ALU: alu_result = src1 | src2;
		`OR_ALU:	alu_result = src1 & src2;
		`XOR_ALU: alu_result = src1 ^ src2;
		`SLT_ALU: begin
			if(src1 < src2) alu_result = 32'b1;
			else alu_result = 32'b0;
		end 	
		`SLTU_ALU: begin
			if($unsign(src2) < $unsign(src1)) begin 
				alu_result = 32'b1;
			end
			else alu_result = 31'b0;
		end
		`SUB_ALU: alu_result = src1 - src2;
		`SLL_ALU: alu_result = src1 << src2[4:0];
		`SRL_ALU: alu_result = src1 >> src1[4:0];
		`SRA_ALU: alu_result = src1 >>> src2[4:0];
		`AM_ALU:  alu_result = (src1 + src2) >> 1'b1;
	endcase // alu_op
end
endmodule