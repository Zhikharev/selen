// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME        	   	:core_if_s.sv
// PROJECT                	:Selen
// AUTHOR              		: Alexsandr Bolotnokov
// AUTHOR'S EMAIL 		:AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        	:decode phase of pipline 
// ----------------------------------------------------------------------------
module cpu_dec_s(
	input								clk,//system clock
	input 								rst_n,//system reset
	//reg cntrl 	
	input 								dec_enb,
	input								dec_kill,// clear decode/execution register
	//inside terminals
	input 								dec_nop_gen_in,//
	input[31:0]							dec_inst_in,//instruction from level 1 instruction cashe
	input[31:0]							dec_data_wrt_in,//data for write to register file
	input								dec_il1_ack_in,// acknowlegment from level 1 instruction cashe
	input								dec_we_reg_file_in,// write enable for register file
	//input form if station
	input[31:0]							dec_pc_in,
	input[31:0]							dec_pc_4_in,
	// 2 exe station
	output reg [2:0]		 			dec_wb_sx_op_out_reg,
	output reg 							dec_we_reg_file_out_reg,		
	output reg [31:0]					dec_src1_out_reg,
	output reg [31:0]					dec_src2_out_reg,
	output reg [31:0]					dec_pc_out_reg,
	output reg [31:0]					dec_pc_4_out_reg,
	output reg [31:0]					dec_sx_imm_out_reg,
	output reg [6:0]					dec_ld1_out_reg,// consistes of the MSB is validation of request, then 1'b0 is rezerved after  
	//the nex 2 bits are  casheble or uncasheble and read or write respectively the last 3 bits mean size of request to mem
	output reg [5:0]					dec_mux_bus_out_reg,
	output reg [3:0]					dec_alu_op_out_reg,	
	output reg [2:0] 	 				dec_alu_cnd_out_reg,// the MSB equals 1 means there is a branch command
	output reg[ 14:0]					dec_hazard_bus_out_reg,
	// for hazard 
	output reg [1:0]					dec_hazard_cmd_out_reg,// signals to hazard
	output								dec_stall_out// signal detecting absent of data from cashe
);
reg 				dec_we_reg_file_loc_nop;
reg 				dec_ld1_loc_nop;
reg 				dec_order_loc;
reg[2:0] 		sx_loc;
reg[2:0]		wb_sx_loc;
reg[2:0] 		dec_wb_sx_op_loc;
reg 				dec_we_reg_file_loc;		
reg[31:0]		dec_src1_loc;
reg[31:0]		dec_src2_loc;
reg[31:0]		dec_sx_imm_loc;
reg[31:0]		dec_ld1_loc;
reg[5:0]		dec_mux_bus_loc;
reg[2:0]		dec_brnch_cnd_loc;
reg[3:0]		alu_op;	
reg[3:0] 		dec_alu_cnd_loc;
reg[14:0]		dec_hazard_bus_loc;
wire[4:0]		rs1;
wire [4:0]	rs2;
reg[1:0]		dec_hazard_cmd_loc;
//controll unit
always @* begin
	//initial assinging
	dec_we_reg_file_loc = `WE_OFF;
	dec_order_loc = `ORDER_OFF;
	dec_ld1_loc = `NOT_REQ;
	dec_wb_sx_op_loc = `WB_SX_BP;
	sx_loc = 3'b000;
	dec_hazard_cmd_loc = `HZRD_OTHER;
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
						`OR:	alu_op = 	`OR_ALU;
						`XOR:	alu_op = 	`XOR_ALU;
						`SLL:	alu_op = 	`SLL_ALU;
						`SRL:	alu_op = 	`SRL_ALU;
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
			dec_mux_bus_loc = `LD_OPCODE;
			dec_we_reg_file_loc = `WE_ON;
			sx_loc = `SX_LD_I_R_JALR;
			dec_hazard_cmd_loc = `HZRD_LOAD;		
			case(dec_inst_in[14:12])
				`LW:begin
					dec_ld1_loc = `LW_L1D;
					dec_wb_sx_op_loc = `WB_SX_BP;
				end
				`LH:begin
					dec_ld1_loc = `LH_L1D;
					dec_wb_sx_op_loc = `WB_SX_H;
				end
				`LHU:begin
					dec_ld1_loc = `LH_L1D;
					dec_wb_sx_op_loc = `WB_SX_UH;
				end
				`LB:begin
					dec_ld1_loc = `LB_L1D;
					dec_wb_sx_op_loc = `WB_SX_B;
				end
				`LBU:begin
					dec_ld1_loc = `LB_L1D;
					dec_wb_sx_op_loc = `WB_SX_UB;
				end	
			endcase // FNCT3 for load 
		end
		
		`ST_OPCODE: begin 
			dec_mux_bus_loc = `ST_MUX;
			sx_loc = `SX_ST;
			case(dec_inst_in[14:12])
				`SW: dec_ld1_loc = `SW_L1D;
				`SH: dec_ld1_loc = `SH_L1D;
				`SB: dec_ld1_loc = `SB_L1D;
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
		.clk(clk),
		.rst_n(rst_n),
		.rs1(rs1),
		.rs2(rs2),
		.rd(dec_inst_in[11:7]),
		.data_in(dec_data_wrt_in),
		.we(dec_we_reg_file_in),
		.order(dec_order_loc),
		.src1_out_r(dec_src1_loc),
		.src2_out_r(dec_src2_loc)
		);
	always@(posedge clk) begin
		if(dec_enb)begin
			dec_ld1_out_reg <= dec_ld1_loc_nop;
			dec_mux_bus_out_reg <= dec_mux_bus_loc;
			dec_hazard_bus_out_reg <= dec_hazard_bus_loc;
			dec_alu_cnd_out_reg <= dec_alu_cnd_loc;
			dec_alu_op_out_reg <= alu_op;
			dec_src1_out_reg <= dec_src1_loc;	
			dec_src2_out_reg <= dec_src2_loc;
			dec_pc_out_reg <=  	dec_pc_in;
			dec_pc_4_out_reg <= dec_pc_4_in;
			dec_sx_imm_out_reg <= sx_loc;
			dec_we_reg_file_out_reg <= dec_we_reg_file_loc_nop;
			dec_hazard_cmd_out_reg <= dec_hazard_cmd_loc;
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
			dec_hazard_cmd_out_reg <= 0;
		end	
end 
assign dec_hazard_bus_loc = {rs1,rs2,dec_inst_in[11:7]};
assign dec_stall_in = (dec_il1_ack_in)? 1'b0:1'b1;
assign dec_ld1_loc_nop = (dec_nop_gen_in)?`NOT_REQ : dec_ld1_loc;
assign dec_we_reg_file_loc_nop = (dec_nop_gen_in)? `WE_OFF : dec_we_reg_file_loc;
assign rs1 = (dec_nop_gen_in)? 5'b0: dec_inst_in[19:15];
assign rs2 = (dec_nop_gen_in)? 5'b0: dec_inst_in[24:20];	
endmodule // cpu_dec_s

