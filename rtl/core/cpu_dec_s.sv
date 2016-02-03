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
	input 							dec_nop_gen,//
	input[31:0]					dec_inst,//instruction from level 1 instruction cashe
	input[31:0]					dec_data_wrt,//data for write to register file
	input								dec_kill,// clear decode/execution register
	input 							dec_enb,
	input								dec_il1_ack,// acknowlegment from level 1 instruction cashe
	input								dec_we_reg_file_in,// write enable for register file
	output							dec_stall,// signal detecting absent of data from cashe
	output 				reg 	dec_order_out_reg,// order for register file, exsist only inside of decode stage

	output[2:0]		reg 	dec_wb_sx_op_out_reg,
	output				reg 	dec_we_reg_file_out_reg,		
	output[31:0]	reg		dec_src1_out_reg,
	output[31:0]	reg		dec_src2_out_reg,
	output[31:0]	reg		dec_pc_out_reg,
	output[31:0]	reg		dec_pc_4_out_reg,
	output[31:0]	reg		dec_sx_imm_out_reg,
	output[6:0]		reg		dec_ld1_out_reg,// consistes of the MSB is validation of request, then 1'b0 is rezerved after  
	//the nex 2 bits are  casheble or uncasheble and read or write respectively the last 3 bits mean size of request to mem
	output[5:0]		reg		dec_mux_bus_out_reg,
	output[2:0]		reg		dec_brnch_cnd_out_reg,
	output[3:0]		reg		dec_alu_op_out_reg,	
	output[2:0] 	reg 	dec_alu_cnd_out_reg,// the MSB equals 1 means there is a branch command
	output[14:0]	reg		dec_hazard_bus_out_reg
);
reg 				dec_order_loc;
reg[2:0] 	sx_loc;
reg[2:0] 		dec_wb_sx_op_loc;
reg 				dec_we_reg_file_loc;		
reg[31:0]		dec_src1_loc;
reg[31:0		dec_src2_loc;
reg[31:0]		dec_pc_loc;
reg[31:0]		dec_pc_4_loc;
reg[31:0]		dec_sx_imm_loc;
reg[31:0]		dec_ld1_loc;
reg[5:0]		dec_mux_bus_loc;
reg[2:0]		dec_brnch_cnd_loc;
reg[3:0]		dec_alu_op_loc;	
reg[3:0] 		dec_alu_cnd_loc;
reg[14:0]		dec_hazard_bus_loc;
wire[4:0]		rs1;
wire [4:0]	rs2;
//controll unit
always @* begin
	//initial assinging
	dec_we_reg_file_loc = WE_OFF;
	dec_order_loc = ORDER_OFF;
	dec_ld1_loc = NOT_REQ;
	dec_wb_sx_op_loc = SX_BP;
	sx_loc = 3'bx
	case(dec_inst[5:0])
		R_OPCODE:begin
			dec_mux_bus_loc = R_MUX;
			dec_we_reg_file_loc = WE_ON;
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
			dec_mux_bus_loc = I_R_MUX;
			dec_we_reg_file_loc = WE_ON;
			sx_loc = SX_LD_I_R_JALR;
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
		
		LUI__OPCODE:begin
			 dec_mux_bus_loc = LUI_MUX;
				sx_loc = SX_AUIPC_LUI;
		end // LUI__OPCODE:
		AUIPC_OPCODE: begin
			sx_loc = SX_AUIPC_LUI; 
			dec_mux_bus_loc = AUIPC_MUX;
			dec_we_reg_file_loc = WE_ON;
			alu_op = ADD_ALU;
		end//AUIPC_OPCODE
		
		SB_OPCODE: begin
			sx_loc = SX_SB:
			dec_mux_bus_loc = SB_MUX;
			case(dec_inst[14:12])
				BEQ:begin
					dec_order_loc = ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,ALU_BEQ};
				end
				BNE:begin
					dec_order_loc = ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,ALU_BNE};
				end	
				BLT:begin
					dec_order_loc = ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,ALU_BLT};
				end
				BLTU:begin
					dec_order_loc = ORDER_OFF;
					dec_alu_cnd_loc = {1'b1,ALU_BLTU};
				end
				BGE:begin
					dec_order_loc = ORDER_ON;
					dec_alu_cnd_loc = {1'b1,ALU_BLT};
				end
				BGEU:begin
					dec_order_loc = ORDER_ON;
					dec_alu_cnd_loc = {1'b1,ALU_BLTU};
				end
			endcase // FNCT3 for branches
		end
		
		UJ_OPCODE:begin 
			sx_loc = SX_UJ_JAL;
			dec_mux_bus_loc = UJ_MUX;
			dec_we_reg_file_loc = WE_ON;
		end
		
		JALR_OPCODE: begin
			sx_loc = SX_LD_I_R_JALR;
			dec_mux_bus_loc  = JALR_MUX;
			dec_we_reg_file_loc = WE_ON;
		end
		
		LD_OPCODE: begin
			dec_mux_bus_loc = LD_OPCODE;
			dec_we_reg_file_loc = WE_ON;
			sx_loc = SX_LD_I_R;		
			case(dec_inst[14:12])
				LW:begin
					dec_ld1_loc = LW_DL1;
					dec_wb_sx_op_loc = SX_BP;	
				end
				LH:begin
					dec_ld1_loc = LH_DL1;
					dec_wb_sx_op_loc = SX_H;
				end
				LHU:begin
					dec_ld1_loc = LH_DL1;
					dec_wb_sx_op_loc = SX_HU;
				end
				LB:begin
					dec_ld1_loc = LB_DL1;
					dec_wb_sx_op_loc = SX_B;
				end
				LBU:begin
					dec_ld1_loc = LB_DL1;
					dec_wb_sx_op_loc = SX_BU;
				end	
			endcase // FNCT3 for load 
		end
		
		ST_OPCODE: begin 
			dec_mux_bus_loc = ST_MUX;
			sx_loc = SX_ST;
			case(dec_inst[14:12])
				SW: dec_ld1_loc = SW_LD1;
				SH: dec_ld1_loc = SH_LD1;
				SB: dec_ld1_loc = SB_DL1;
			endcase // FNCT3	
		end
	endcase // OPCODE DECODE main case
end
//sign extension
always @* begin
	case(sx_loc)
		SX_LD_I_R_JALR:dec_sx_imm_loc = {20{dec_inst[31]},dec_inst[31:20]};
		SX_AUIPC_LUI: dec_sx_imm_loc = {12{dec_inst[31]},dec_inst[31:12]};
		SX_SB: dec_sx_imm_loc = {20{dec_inst[31]},dec_inst[31],dec_inst[7],dec_inst[30:25],dec_inst[11:8]};
		SX_UJ_JAL: dec_sx_imm_loc = {12{dec_inst[31]},dec_inst[31],dec_inst[19:12],dec_inst[20],dec_inst[30:21]};
		SX_ST: dec_sx_imm_loc = {20{dec_inst[31]},dec_inst[31:25],dec_inst[11:7]};
	endcase//sx_loc	
end	
	//conections of register file
	core_reg_file reg_file (
		.clk(clk),
		.rst_n(rst_n),
		.rs1(rs1),
		.rs2(rs2),
		.rd(dec_inst[11:7]),
		.data_in(dec_data_wrt),
		.we(dec_we_reg_file_in),
		.order(dec_order_loc),
		.src1_out_r(dec_src1_loc),
		.src2_out_r(dec_src2_loc)
		);
	always@(posedge clk) begin
		if(dec_enb)begin
			dec_ld1_out_reg <= dec_ld1_loc;
			dec_mux_bus_out_reg <= dec_mux_bus_loc;
			dec_hazard_bus_out_reg <= dec_hazard_bus_loc;
			dec_alu_cnd_out_reg <= dec_alu_cnd_loc;
			dec_alu_op_out_reg <= dec_alu_op_loc;
			dec_src1_out_reg <= dec_src1_loc;	
			dec_src2_out_reg <= dec_src2_loc;
			dec_pc_out_reg <=  	dec_pc_loc;
			dec_pc_4_out_reg <= dec_pc_4_loc;
			dec_sx_imm_out_reg <= dec_sx_loc;
			dec_we_reg_file_out_reg <= dec_we_reg_file_loc;
			dec_hazard_bus_out_reg <= dec_hazard_bus_loc;
		end	
		else begin
		end	
		if(dec_kill)begin
			dec_ld1_out_reg <= 0;
			dec_mux_bus_out_reg <= 0;
			dec_hazard_bus_out_reg <= 0;
			dec_alu_cnd_out_reg <= 0;
			dec_alu_op_out_reg <= 0;
			dec_src1_out_reg <= 	0;
			dec_src2_out_reg <= 	0;
			dec_pc_out_reg <=  		0;
			dec_pc_4_out_reg <=  	0;
			dec_sx_imm_out_reg <= 0;
			dec_we_reg_file_out_reg <= 0;
			dec_hazard_bus_out_reg <= 0;
		end	
end 
assign dec_hazard_bus_loc = {rs1,rs2,dec_inst[11:7]};
assign dec_stall = (dec_il1_ack)? 1'b0;1'b1;
assign dec_ld1_loc = (dec_nop_gen)?NOT_REQ : dec_ld1_loc;
assign dec_we_reg_file_loc = (dec_nop_gen)? WE_OFF : dec_we_reg_file_loc;
assign rs1 = (dec_nop_gen)? 5'b0: dec_inst[19:15];
assign rs2 = (dec_nop_gen)? 5'b0: dec_inst[24:20];	
endmodule // cpu_dec_s

