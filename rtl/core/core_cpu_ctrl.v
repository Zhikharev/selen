// ----------------------------------------------------------------------------
// FILE NAME            	: core_csr.sv
// PROJECT                : Selen
// AUTHOR                 :	Alexandr Bolotnikov	
// AUTHOR'S EMAIL 				:	AlexsanrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		:	The core control unit 
// ----------------------------------------------------------------------------
// include core_defines.vh;
// include opcodes.vh;
module core_cpu_ctrl(
input[31:0] 	ctrl_inst_in,
//to reg 
output[2:0]		ctrl_wb_sx_op_out,
output[5:0]		ctrl_mux_bus_out,
output[3:0]		ctrl_alu_op_out,
output[2:0]		ctrl_alu_cnd_out,
output 				ctrl_we_reg_file_out,
output[2:0]		ctrl_l1d_size_out,
output				ctrl_l1d_cop_lsb_out,
output 				ctrl_l1d_val_out, 				
//inner for decode phase 
output				ctrl_order_reg_file_out,
output[2:0]		ctrl_dec_sx_op_out,
output[1:0]		ctrl_haz_cmd_out,
//error
output 				ctrl_error_out
);
reg[2:0] 	wb_sx_op_loc;
reg[5:0]	mux_bus_loc;
reg[3:0] 	alu_op_loc;
reg[2:0]	alu_cnd_loc;
reg 			we_reg_file_loc;
reg 			l1d_val_loc;
reg[2:0]	l1d_size_loc;
reg 			l1d_cop_loc;

reg 			order_loc;
reg[2:0]	dec_sx_op_loc;
reg[1:0]	hazard_cmd_loc;

reg 			error_loc; 
always @* begin
	//initial assinging
	we_reg_file_loc = `WE_OFF;
	order_loc = `ORDER_OFF;
	wb_sx_op_loc = `WB_SX_BP;
	dec_sx_op_loc = 3'b000;
	hazard_cmd_loc = `HZRD_OTHER;
	l1d_val_loc = `DL1_VAL_OFF;
	error_loc = 1'b0;
	alu_cnd_loc[2] = 1'b0;
	case(ctrl_inst_in[5:0])
		`R_OPCODE:begin
			mux_bus_loc = `R_MUX;
			we_reg_file_loc = `WE_ON;
			case(ctrl_inst_in[31:25])// function 7 feald case
				`FNCT7_1:begin
					case(ctrl_inst_in[14:12])//functoin 3 feald case
						`ADD: 	alu_op_loc = 	`ADD_ALU;
						`SLT: 	alu_op_loc = 	`SLT_ALU;
						`SLTU:  alu_op_loc = 	`SLTU_ALU;
						`AND: 	alu_op_loc = 	`AND_ALU;
						`OR:		alu_op_loc = 	`OR_ALU;
						`XOR:		alu_op_loc = 	`XOR_ALU;
						`SLL:		alu_op_loc = 	`SLL_ALU;
						`SRL:		alu_op_loc = 	`SRL_ALU;
					endcase//FNCT3	
				end//FNCT7_1		
				`FNCT7_2:begin
					case(ctrl_inst_in[14:12])
						`SUB:	alu_op_loc = `SUB_ALU;
						`SRA:	alu_op_loc = `SRA_ALU;
						`AM:	alu_op_loc = `AM_ALU;
					endcase//FNCT3	
				end	// FNCT7_2
			endcase // FNCT7	
		end// R_OPCODE
		
		`I_R_OPCODE: begin 
			mux_bus_loc = `I_R_MUX;
			we_reg_file_loc = `WE_ON;
			dec_sx_op_loc = `SX_LD_I_R_JALR;
			case(ctrl_inst_in[14:12])//functoin 3 feald case
				`ADD: 	alu_op_loc = `ADD_ALU;
				`SLT: 	alu_op_loc = `SLT_ALU;
				`SLTU: 	alu_op_loc = `SLTU_ALU;
				`AND: 	alu_op_loc = `AND_ALU;
				`OR:		alu_op_loc = `OR_ALU;
				`XOR:		alu_op_loc = `XOR_ALU;
				`SLL:		alu_op_loc = `SLL_ALU;
				`SRL:		alu_op_loc = `SRL_ALU;
			endcase//FNCT3
		end//I_R_OPCODE
		
		`LUI_OPCODE:begin
			mux_bus_loc = `LUI_MUX;
			dec_sx_op_loc = `SX_AUIPC_LUI;
			wb_sx_op_loc = `WB_SX_IMM;
		end // LUI__OPCODE:
		`AUIPC_OPCODE: begin
			dec_sx_op_loc = `SX_AUIPC_LUI; 
			mux_bus_loc = `AUIPC_MUX;
			we_reg_file_loc = `WE_ON;
			alu_op_loc = `ADD_ALU;
		end//AUIPC_OPCODE
		
		`SB_OPCODE: begin
			dec_sx_op_loc = `SX_SB;
			mux_bus_loc = `SB_MUX;
			hazard_cmd_loc = `HZRD_BRNCH;
			case(ctrl_inst_in[14:12])
				`BEQ:begin
					order_loc = `ORDER_OFF;
					alu_cnd_loc = {1'b1,`ALU_BEQ};
				end
				`BNE:begin
					order_loc = `ORDER_OFF;
					alu_cnd_loc = {1'b1,`ALU_BNE};
				end	
				`BLT:begin
					order_loc = `ORDER_OFF;
					alu_cnd_loc = {1'b1,`ALU_BLT};
				end
				`BLTU:begin
					order_loc = `ORDER_OFF;
					alu_cnd_loc = {1'b1,`ALU_BLTU};
				end
				`BGE:begin
					order_loc = `ORDER_ON;
					alu_cnd_loc = {1'b1,`ALU_BLT};
				end
				`BGEU:begin
					order_loc = `ORDER_ON;
					alu_cnd_loc = {1'b1,`ALU_BLTU};
				end
			endcase // FNCT3 for branches
		end
		
		`UJ_OPCODE:begin 
			dec_sx_op_loc = `SX_UJ_JAL;
			mux_bus_loc = `UJ_MUX;
			we_reg_file_loc = `WE_ON;
			wb_sx_op_loc = `WB_SX_PC;
			hazard_cmd_loc = `HZRD_JUMP;
		end
		
		`JALR_OPCODE: begin
			dec_sx_op_loc = `SX_LD_I_R_JALR;
			mux_bus_loc  = `JALR_MUX;
			we_reg_file_loc = `WE_ON;
			wb_sx_op_loc = `WB_SX_PC;
			hazard_cmd_loc = `HZRD_JUMP;
		end
		
		`LD_OPCODE: begin
			mux_bus_loc = `LD_MUX;
			we_reg_file_loc = `WE_ON;
			dec_sx_op_loc = `SX_LD_I_R_JALR;
			hazard_cmd_loc = `HZRD_LOAD;		
			case(ctrl_inst_in[14:12])
				`LW:begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_READ;
					l1d_size_loc = `DL1_SIZE_WORD;
					wb_sx_op_loc = `WB_SX_BP;
				end
				`LH:begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_READ;
					l1d_size_loc = `DL1_SIZE_HALF;
					wb_sx_op_loc = `WB_SX_H;
				end
				`LHU:begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_READ;
					l1d_size_loc = `DL1_SIZE_HALF;
					wb_sx_op_loc = `WB_SX_UH;
				end
				`LB:begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_READ;
					l1d_size_loc = `DL1_SIZE_BYTE;
					wb_sx_op_loc = `WB_SX_B;
				end
				`LBU:begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_READ;
					l1d_size_loc = `DL1_SIZE_BYTE;
					wb_sx_op_loc = `WB_SX_UB;
				end	
			endcase // FNCT3 for load 
		end
		
		`ST_OPCODE: begin 
			mux_bus_loc = `ST_MUX;
			dec_sx_op_loc = `SX_ST;
			case(ctrl_inst_in[14:12])
				`SW: begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_WRT;
					l1d_size_loc = `DL1_SIZE_WORD;
					wb_sx_op_loc = `WB_SX_BP;
				end
				`SH: begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_WRT;
					l1d_size_loc = `DL1_SIZE_HALF;
					wb_sx_op_loc = `WB_SX_H;
				end
				`SB: begin
					l1d_val_loc = `DL1_VAL_ON;
					l1d_cop_loc = `DL1_WRT;
					l1d_size_loc = `DL1_SIZE_WORD;
					wb_sx_op_loc = `WB_SX_B;
				end
			endcase // FNCT3	
		end
	default error_loc = 1'b1;
	endcase // OPCODE DECODE main case
end

assign ctrl_wb_sx_op_out = wb_sx_op_loc;
assign ctrl_l1d_val_out = l1d_val_loc;
assign ctrl_l1d_size_out = l1d_size_loc;
assign ctrl_l1d_cop_lsb_out = l1d_cop_loc;
assign ctrl_mux_bus_out = mux_bus_loc;
assign ctrl_alu_op_out = alu_op_loc;
assign ctrl_alu_cnd_out = alu_cnd_loc;
assign ctrl_we_reg_file_out = we_reg_file_loc;
assign ctrl_order_reg_file_out = order_loc;
assign ctrl_ctrl_order_reg_file_out = order_loc;
assign ctrl_dec_sx_op_out = dec_sx_op_loc;
assign ctrl_haz_cmd_out = hazard_cmd_loc;
assign ctrl_error_out =  error_loc;
endmodule
