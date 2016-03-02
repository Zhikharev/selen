// ----------------------------------------------------------------------------
// FILE NAME            	: core_csr.sv
// PROJECT                : Selen
// AUTHOR                 :	Alexandr Bolotnikov	
// AUTHOR'S EMAIL 				:	AlexsanrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		:	A description of decode station
// ----------------------------------------------------------------------------
//include core_defines.vh;
//include opcodes.vh;
module core_dec_s(
	input					clk,
	input					rst_n,
	input 					dec_enb,
	input					dec_kill,
	//inside terminals
	input 					dec_nop_gen_in,
	input[31:0]				dec_inst_in,
	input[31:0]				dec_data_wrt_in,
	input					dec_l1i_ack_in,
	input					dec_we_reg_file_in,
	//input form if station
	input[31:0]				dec_pc_in,
	input[31:0]				dec_pc_4_in,
	// 2 exe station
	//control pins
	output reg[2:0]		dec_wb_sx_op_out_reg,
	output reg[5:0]		dec_mux_bus_out_reg,
	output reg 			dec_we_reg_file_out_reg,		
	output reg[3:0]		dec_alu_op_out_reg,	
	output reg[2:0] 	dec_alu_cnd_out_reg,
	//cahs
	output reg 				dec_l1d_req_val_out_reg,
	output reg 			 	dec_l1d_req_cop_out_reg,
	output reg[2:0]		dec_l1d_req_size_out_reg,
	//	information pins
	output reg[31:0]	dec_src1_out_reg,
	output reg[31:0]	dec_src2_out_reg,
	output reg[31:0]	dec_sx_imm_out_reg,
	output reg[31:0]	dec_pc_out_reg,
	output reg[31:0]	dec_pc_4_out_reg,
	//
	output reg[4:0]		dec_rs1_out_reg,
	output reg[4:0]		dec_rs2_out_reg,
	output reg[4:0]		dec_rd_out_reg,
	// for hazard 
	output reg[1:0]		dec_hazard_cmd_out_reg,
	output[1:0]				dec2haz_cmd_out,
	output						dec_stall_out,

	//validation of instruction 
	output reg 			dec_val_inst_out_reg
);
wire				dec_we_reg_file_loc_nop;

reg 				l1i_val_loc;
reg[2:0] 		l1i_size_loc; 
reg 				l1i_cop_loc;

reg 				dec_order_loc;
reg[2:0] 		sx_loc;
reg[2:0]		wb_sx_loc;
reg[2:0] 		dec_wb_sx_op_loc;
reg 				dec_we_reg_file_loc;		
reg[6:0]		dec_ld1_loc;
reg[2:0]		dec_brnch_cnd_loc;
reg[5:0]		dec_mux_bus_loc;
reg[3:0]		alu_op;	

reg[31:0]		dec_src1_loc;
reg[31:0]		dec_src2_loc;
reg[31:0]		dec_sx_imm_loc;
reg[3:0] 		dec_alu_cnd_loc;
reg[14:0]		dec_hazard_bus_loc;
wire[4:0]		rs1;
wire[4:0]		rs2;
wire[4:0]		rd;
reg[1:0]		dec_hazard_cmd_loc;
wire 				l1i_val_loc_nop;
//controll unit
always @* begin
	//initial assinging
	dec_we_reg_file_loc = `WE_OFF;
	dec_order_loc = `ORDER_OFF;
	dec_wb_sx_op_loc = `WB_SX_BP;
	sx_loc = 3'b000;
	dec_hazard_cmd_loc = `HZRD_OTHER;
	l1i_val_loc = `DL1_VAL_OFF;
	case(dec_inst_in[5:0])
		`R_OPCODE:begin
			dec_mux_bus_loc = `R_MUX;
			dec_we_reg_file_loc = `WE_ON;
			case(dec_inst_in[31:25])// function 7 feald case
				`FNCT7_1:begin
					case(dec_inst_in[14:12])//functoin 3 feald case
						`ADD: 	alu_op = 	`ADD_ALU;
						`SLT: 	alu_op = 	`SLT_ALU;
						`SLTU:  alu_op = 	`SLTU_ALU;
						`AND: 	alu_op = 	`AND_ALU;
						`OR:		alu_op = 	`OR_ALU;
						`XOR:		alu_op = 	`XOR_ALU;
						`SLL:		alu_op = 	`SLL_ALU;
						`SRL:		alu_op = 	`SRL_ALU;
					endcase//FNCT3	
				end//FNCT7_1		
				`FNCT7_2:begin
					case(dec_inst_in[14:12])
						`SUB:	alu_op = `SUB_ALU;
						`SRA:	alu_op = `SRA_ALU;
						`AM:	alu_op = `AM_ALU;
					endcase//FNCT3	
				end	// FNCT7_2
			endcase // FNCT7	
		end// R_OPCODE
		
		`I_R_OPCODE: begin 
			dec_mux_bus_loc = `I_R_MUX;
			dec_we_reg_file_loc = `WE_ON;
			sx_loc = `SX_LD_I_R_JALR;
			case(dec_inst_in[14:12])//functoin 3 feald case
				`ADD: 	alu_op = `ADD_ALU;
				`SLT: 	alu_op = `SLT_ALU;
				`SLTU: 	alu_op = `SLTU_ALU;
				`AND: 	alu_op = `AND_ALU;
				`OR:		alu_op = `OR_ALU;
				`XOR:		alu_op = `XOR_ALU;
				`SLL:		alu_op = `SLL_ALU;
				`SRL:		alu_op = `SRL_ALU;
			endcase//FNCT3
		end//I_R_OPCODE
		
		`LUI_OPCODE:begin
			dec_mux_bus_loc = `LUI_MUX;
			sx_loc = `SX_AUIPC_LUI;
			dec_wb_sx_op_loc = `WB_SX_IMM;
		end // LUI__OPCODE:
		`AUIPC_OPCODE: begin
			sx_loc = `SX_AUIPC_LUI; 
			dec_mux_bus_loc = `AUIPC_MUX;
			dec_we_reg_file_loc = `WE_ON;
			alu_op = `ADD_ALU;
		end//AUIPC_OPCODE
		
		`SB_OPCODE: begin
			sx_loc = `SX_SB;
			dec_mux_bus_loc = `SB_MUX;
			dec_hazard_cmd_loc = `HZRD_BRNCH;
			case(dec_inst_in[14:12])
				`BEQ:begin
					dec_order_loc = `ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,`ALU_BEQ};
				end
				`BNE:begin
					dec_order_loc = `ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,`ALU_BNE};
				end	
				`BLT:begin
					dec_order_loc = `ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,`ALU_BLT};
				end
				`BLTU:begin
					dec_order_loc = `ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,`ALU_BLTU};
				end
				`BGE:begin
					dec_order_loc = `ORDER_ON;
					dec_alu_cnd_loc = {1'b1,`ALU_BLT};
				end
				`BGEU:begin
					dec_order_loc = `ORDER_ON;
					dec_alu_cnd_loc = {1'b1,`ALU_BLTU};
				end
			endcase // FNCT3 for branches
		end
		
		`UJ_OPCODE:begin 
			sx_loc = `SX_UJ_JAL;
			dec_mux_bus_loc = `UJ_MUX;
			dec_we_reg_file_loc = `WE_ON;
			dec_wb_sx_op_loc = `WB_SX_PC;
			dec_hazard_cmd_loc = `HZRD_JUMP;
		end
		
		`JALR_OPCODE: begin
			sx_loc = `SX_LD_I_R_JALR;
			dec_mux_bus_loc  = `JALR_MUX;
			dec_we_reg_file_loc = `WE_ON;
			dec_wb_sx_op_loc = `WB_SX_PC;
			dec_hazard_cmd_loc = `HZRD_JUMP;
		end
		
		`LD_OPCODE: begin
			dec_mux_bus_loc = `LD_MUX;
			dec_we_reg_file_loc = `WE_ON;
			sx_loc = `SX_LD_I_R_JALR;
			dec_hazard_cmd_loc = `HZRD_LOAD;		
			case(dec_inst_in[14:12])
				`LW:begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_READ;
					l1i_size_loc = `DL1_SIZE_WORD;
					dec_wb_sx_op_loc = `WB_SX_BP;
				end
				`LH:begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_READ;
					l1i_size_loc = `DL1_SIZE_HALF;
					dec_wb_sx_op_loc = `WB_SX_H;
				end
				`LHU:begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_READ;
					l1i_size_loc = `DL1_SIZE_HALF;
					dec_wb_sx_op_loc = `WB_SX_UH;
				end
				`LB:begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_READ;
					l1i_size_loc = `DL1_SIZE_BYTE;
					dec_wb_sx_op_loc = `WB_SX_B;
				end
				`LBU:begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_READ;
					l1i_size_loc = `DL1_SIZE_BYTE;
					dec_wb_sx_op_loc = `WB_SX_UB;
				end	
			endcase // FNCT3 for load 
		end
		
		`ST_OPCODE: begin 
			dec_mux_bus_loc = `ST_MUX;
			sx_loc = `SX_ST;
			case(dec_inst_in[14:12])
				`SW: begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_WRT;
					l1i_size_loc = `DL1_SIZE_WORD;
					dec_wb_sx_op_loc = `WB_SX_BP;
				end
				`SH: begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_WRT;
					l1i_size_loc = `DL1_SIZE_HALF;
					dec_wb_sx_op_loc = `WB_SX_H;
				end
				`SB: begin
					l1i_val_loc = `DL1_VAL_ON;
					l1i_cop_loc = `DL1_WRT;
					l1i_size_loc = `DL1_SIZE_WORD;
					dec_wb_sx_op_loc = `WB_SX_B;
				end
			endcase // FNCT3	
		end
	endcase // OPCODE DECODE main case
end
//sign extension
always @* begin
	case(sx_loc)
		`SX_LD_I_R_JALR:dec_sx_imm_loc = $signed({{dec_inst_in[31]},dec_inst_in[31:20]});
		`SX_AUIPC_LUI: dec_sx_imm_loc = $signed({{dec_inst_in[31]},dec_inst_in[31:12]});
		`SX_SB: dec_sx_imm_loc = $signed({{dec_inst_in[31]},dec_inst_in[31],dec_inst_in[7],dec_inst_in[30:25],dec_inst_in[11:8]});
		`SX_UJ_JAL: dec_sx_imm_loc = $signed({{dec_inst_in[31]},dec_inst_in[31],dec_inst_in[19:12],dec_inst_in[20],dec_inst_in[30:21]});
		`SX_ST: dec_sx_imm_loc = $signed({{dec_inst_in[31]},dec_inst_in[31:25],dec_inst_in[11:7]});
	endcase//sx_loc	
end	
	//conections of register file
	core_reg_file reg_file (
		.clk 				(clk),
		.rst_n 			(rst_n),
		.rs1 				(rs1),
		.rs2 				(rs2),
		.rd 				(dec_inst_in[11:7]),
		.data_in 		(dec_data_wrt_in),
		.we 				(dec_we_reg_file_in),
		.order 			(dec_order_loc),
		.src1_out 	(dec_src1_loc),
		.src2_out 	(dec_src2_loc)
		);

	always@(negedge clk) begin
		if(dec_enb)begin
			dec_l1d_req_val_out_reg <= l1i_val_loc_nop;
			dec_l1d_req_cop_out_reg <= l1i_cop_loc;
			dec_l1d_req_size_out_reg <= l1i_size_loc;
			dec_mux_bus_out_reg <= dec_mux_bus_loc;
			dec_alu_cnd_out_reg <= dec_alu_cnd_loc;
			dec_alu_op_out_reg <= alu_op;
			dec_src1_out_reg <= dec_src1_loc;	
			dec_src2_out_reg <= dec_src2_loc;
			dec_pc_out_reg <=  	dec_pc_in;
			dec_pc_4_out_reg <= dec_pc_4_in;
			dec_sx_imm_out_reg <= sx_loc;
			dec_we_reg_file_out_reg <= dec_we_reg_file_loc_nop;
			dec_hazard_cmd_out_reg <= dec_hazard_cmd_loc;
			dec_rs1_out_reg <=rs1;
			dec_rs2_out_reg <=rs2;
			dec_rd_out_reg <=rd;
			dec_val_inst_out_reg <= ~dec_nop_gen_in;
		end	
		if(dec_kill)begin
			dec_l1d_req_val_out_reg<=0;
			dec_l1d_req_cop_out_reg<=0;
			dec_l1d_req_size_out_reg<=0;
			dec_mux_bus_out_reg <= 0;
			dec_alu_cnd_out_reg <= 0;
			dec_alu_op_out_reg <= 0;
			dec_src1_out_reg <= 0;
			dec_src2_out_reg <= 0;
			dec_pc_out_reg <= 0;
			dec_pc_4_out_reg <= 0;
			dec_sx_imm_out_reg <= 0;
			dec_we_reg_file_out_reg <= 0;
			dec_hazard_cmd_out_reg <= 0;
			dec_rs1_out_reg <=0;
			dec_rs2_out_reg <=0;
			dec_rd_out_reg <=0;
			dec_val_inst_out_reg <=0;
		end	
end 
assign dec_stall_out = (dec_l1i_ack_in)? 1'b0:1'b1;
assign l1i_val_loc_nop = (dec_nop_gen_in)? 1'b0:l1i_val_loc;
assign dec_we_reg_file_loc_nop = (dec_nop_gen_in)? `WE_OFF : dec_we_reg_file_loc;
assign rs1 = (dec_nop_gen_in)? 5'b0: dec_inst_in[19:15];
assign rs2 = (dec_nop_gen_in)? 5'b0: dec_inst_in[24:20];	
assign rd = (dec_nop_gen_in)? 5'b0: dec_inst_in[11:7];
assign dec2haz_cmd_out = dec_hazard_cmd_loc;
endmodule // cpu_dec_s

