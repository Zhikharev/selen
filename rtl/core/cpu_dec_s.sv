// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        : instruction fetch phase of pipline 
// ----------------------------------------------------------------------------
`include "opcodes.vh"
module cpu_dec_s(
	input								clk,//system clock
	input 							rst_n,//system reset
	input[31:0]					dec_inst,//instruction from level 1 instruction cashe
	input[31:0]					dec_data_wrt,//data for write to register file
	input								dec_kill,// clear rdecode/execution register
	input								dec_il1_ack,// acknowlegment from level 1 instruction cashe
	input								dec_we_reg_file_in,// write enable for register file
	output							dec_stall,// signal detecting absent of data from cashe
	output 				reg 	dec_order_r,// order for register file, exsist only inside of decode stage

	output[2:0]		reg 	dec_wb_sx_op_out_r,
	output				reg 	dec_we_reg_file_out_r,		
	output[31:0]	reg		dec_src1_out_r,
	output[31:0]	reg		dec_src2_out_r,
	output[31:0]	reg		dec_pc_out_r,
	output[31:0]	reg		dec_pc_4_out_r,
	output[31:0]	reg		dec_sx_imm_out_r,
	output[6:0]		reg		dec_ld1_out_r,// consistes of the MSB is validation of request, then 1'b0 is rezerved after  
	//the nex 2 bits are  casheble or uncasheble and read or write respectively the last 3 bits mean size of request to mem
	output[5:0]		reg		dec_mux_bus_out_r,
	output[2:0]		reg		dec_brnch_cnd_out_r,
	output[3:0]		reg		dec_alu_op_out_r,	
	output[3:0] 	reg 	dec_alu_cnd_out_r,// the MSB equals 1 means there is a branch command
	output[14:0]	reg		dec_hazard_bus_out_r
);
reg [1:0] sx;
//controll unit
always @* begin
	//initial assinging
	dec_we_reg_file_out_r = WE_OFF;
	dec_order_r = ORDER_OFF;
	dec_ld1_out_r = NOT_REQ;
	dec_wb_sx_op_out_r = SX_BP;
	case(dec_inst[5:0])
		R_OPCODE:begin
			dec_mux_bus_out_r = R_MUX;
			dec_we_reg_file_out_r = WE_ON;
			case(dec_inst[31:25])// function 7 feald case
				FNCT7_1:begin
					case(dec_inst[14:12])//functoin 3 feald case
						ADD: 	alu_op = ADD_ALU;
						SLT: 	alu_op = SLT_ALU;
						SLTU: alu_op = SLTU_ALU;
						AND: 	alu_op = AND_ALU;
						OR:		alu_op = OR_ALU;
						XOR:	alu_op = XOR_ALU;
						SLL:	alu_op = SLL_ALU;
						SRL:	alu_op = SRL_ALU;
					endcase//FNCT3	
				end//FNCT7_1		
				FNCT7_2:begin
					case(dec_inst[14:12])
						SUB:	alu_op = SUB_ALU;
						SRA:	alu_op = SRA_ALU;
						AM:		alu_op = AM_ALU;
					endcase//FNCT3	
				end	// FNCT7_2
			endcase // FNCT7	
		end// R_OPCODE
		
		I_R_OPCODE: begin 
			dec_mux_bus_out_r = I_R_MUX;
			dec_we_reg_file_out_r = WE_ON;
			case(dec_inst[14:12])//functoin 3 feald case
				ADD: 	alu_op = ADD_ALU;
				SLT: 	alu_op = SLT_ALU;
				SLTU: alu_op = SLTU_ALU;
				AND: 	alu_op = AND_ALU;
				OR:		alu_op = OR_ALU;
				XOR:	alu_op = XOR_ALU;
				SLL:	alu_op = SLL_ALU;
				SRL:	alu_op = SRL_ALU;
			endcase//FNCT3
		end//I_R_OPCODE
		
		LUI__OPCODE: dec_mux_bus_out_r = LUI_MUX;
		
		AUIPC_OPCODE: begin 
			dec_mux_bus_out_r = AUIPC_MUX;
			dec_we_reg_file_out_r = WE_ON;
			alu_op = ADD_ALU;
		end//AUIPC_OPCODE
		
		SB_OPCODE: begin
			dec_mux_bus_out_r = SB_MUX;
			case(dec_inst[14:12])
				BEQ:begin
					dec_order_r = ORDER_OFF;
					dec_alu_cnd_out_r = {1'b1,ALU_BEQ};
				end
				BNE:begin
					dec_order_r = ORDER_OFF;
					dec_alu_cnd_out_r = {1'b1,ALU_BNE};
				end	
				BLT:begin
					dec_order_r = ORDER_OFF;
					dec_alu_cnd_out_r = {1'b1,ALU_BLT};
				end
				BLTU:begin
					dec_order_r = ORDER_OFF;
					dec_alu_cnd_out_r = {1'b1,ALU_BLTU};
				end
				BGE:begin
					dec_order_r = ORDER_ON;
					dec_alu_cnd_out_r = {1'b1,ALU_BLT};
				end
				BGEU:begin
					dec_order_r = ORDER_ON;
					dec_alu_cnd_out_r = {1'b1,ALU_BLTU};
				end
			endcase // FNCT3 for branches
		end
		
		UJ_OPCODE:begin 
			dec_mux_bus_out_r = UJ_MUX;
			dec_we_reg_file_out_r = WE_ON;
		end
		
		JALR_OPCODE: begin
			dec_mux_bus_out_r = JALR_MUX;
			dec_we_reg_file_out_r = WE_ON;
		end
		
		LD_OPCODE: begin
			dec_mux_bus_out_r = LD_OPCODE;
			dec_we_reg_file_out_r = WE_ON;
			case(dec_inst[14:12])
				LW:begin
					dec_ld1_out_r = LW_DL1;
					dec_wb_sx_op_out_r = SX_BP;	
				end
				LH:begin
					dec_ld1_out_r = LH_DL1;
					dec_wb_sx_op_out_r = SX_H;
				end
				LHU:begin
					dec_ld1_out_r = LH_DL1;
					dec_wb_sx_op_out_r = SX_HU;
				end
				LB:begin
					dec_ld1_out_r = LB_DL1;
					dec_wb_sx_op_out_r = SX_B;
				end
				LBU:begin
					dec_ld1_out_r = LB_DL1;
					dec_wb_sx_op_out_r = SX_BU;
				end	
			endcase // FNCT3 for load 
		end
		
		ST_OPCODE: begin 
			dec_mux_bus_out_r = ST_MUX;
			case(dec_inst[14:12])
				SW: dec_ld1_out_r = SW_LD1;
				SH: dec_ld1_out_r = SH_LD1;
				SB: dec_ld1_out_r = SB_DL1;
			endcase // FNCT3	
		end
	endcase // OPCODE DECODE main case
end
always()
endmodule // cpu_dec_s

