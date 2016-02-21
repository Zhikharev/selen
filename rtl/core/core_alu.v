// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : core_alu.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        : arithmetico logical unit
// ----------------------------------------------------------------------------

module 	core_alu (
	input signed [31:0] 						src1,
	input signed [31:0]							src2,
	input[3:0]									alu_op,
	input[2:0]									brnch_cnd,
	output reg  signed  [31:0]	 				alu_result,
	output 		 					reg			brnch_takenn			
);
always @* begin  
	case(alu_op)
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

always @* begin
	if(brnch_cnd[2]) begin
		case(brnch_cnd)
			`ALU_BEQ: begin
					if(src1 == src2) brnch_takenn = 1'b1;
					else brnch_takenn = 1'b0;
			end
			`ALU_BNE: begin
				if(src1 != src2) begin
					brnch_takenn = 1'b1;
				end
				else brnch_takenn = 1'b0;
			end
			`ALU_BLT: begin
				if(src1 < src2) begin
					brnch_takenn = 1'b1;	
				end	
				else	brnch_takenn = 1'b0;
			end
			`ALU_BLTU: begin
				if((~src1 + 32'b1) < (~src1 + 32'b1)) begin
					brnch_takenn = 1'b1;
				end
				else begin
					brnch_takenn = 1'b0;
				end
			end
		endcase // brnch_cnd	
	end
	else brnch_takenn = 1'b0;
end

endmodule