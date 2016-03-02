// ----------------------------------------------------------------------------
// FILE NAME            	: core_csr.sv
// PROJECT                : Selen
// AUTHOR                 :	Alexandr Bolotnikov	
// AUTHOR'S EMAIL 				:	AlexsanrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		:	A description of exeqution station
// ----------------------------------------------------------------------------
//include core_defines.vh;
module core_exe_s (
	input 					exe_val_inst_in,
	input							clk,
	input							rst_n, 
	input							exe_enb,
	input 						exe_kill,
	//
	input							exe_s_frm_haz_mux_trn_in,
	// from deceode 
	//control pins
	input 						exe_we_reg_file_in,
	input[2:0]				exe_wb_sx_op_in,
	input[5:0]				exe_mux_bus_in,
	input[3:0] 				exe_alu_op_in,
	input[2:0]				exe_alu_cnd_in,
	//
	input 						exe_l1d_val_in,
	input[2:0] 				exe_l1d_size_in,
	input 						exe_l1d_cop_in,
	//information pins
	input[31:0] 			exe_src1_in,
	input[31:0]				exe_src2_in,
	input[31:0]				exe_pc_in,
	input[31:0]				exe_pc_4_in,
	input[31:0]				exe_sx_imm_in,
	//for hazard	
	input[4:0]				exe_rs1_in,
	input[4:0]				exe_rs2_in,
	input[4:0] 				exe_rd_in,
	input[31:0]				exe_result_frm_m,
	input[31:0]				exe_result_frm_w,
	input[3:0]				exe_bp_in,
	input[1:0]				exe_haz_cmd_in,	
 	// to memmory
	output reg[2:0]		exe_wb_sx_op_out_reg,
	output reg 				exe_l1d_cop_out_reg,
	output reg 				exe_l1d_val_out_reg,
	output reg[2:0]		exe_l1d_size_out_reg,
	output reg 				exe_we_reg_file_out_reg,
	output reg 				exe_mux_alu_mem_out_reg,
	// exe/mem register
	output reg[31:0]	exe_alu_result_out_reg,
	output reg[31:0]	exe_sx_imm_out_reg,
	output reg[31:0]	exe_pc_4_out_reg,
	output reg[31:0]	exe_w_data_out_reg,
	output reg[31:0]	exe_addr_out_reg,
	output reg				exe_mux_trn_out_reg,
	output reg[31:0]	exe_wrt_data_out_reg,
	//
	output reg[4:0]		exe_rs1_out_reg,
	output reg[4:0] 	exe_rs2_out_reg,
	output reg[4:0]  	exe_rd_out_reg,
	output reg[1:0]		exe_haz_cmd_out_reg,
	//inner pins
	output						exe2haz_brnch_tknn_out, 				
	output 						exe2haz_we_reg_file_out,
	output[4:0] 			exe2haz_rs1_out,
	output[4:0] 			exe2haz_rs2_out,
	output[4:0]				exe2haz_rd_out,
	output[1:0]				exe2haz_cmd_out,
	
	output 				exe_val_inst_out_reg
);	

wire[31:0] 		alu_src1;
wire[31:0] 		alu_src2;
wire[31:0] 		src1_or_imm;
wire[31:0]	 	src2_or_pc;
wire[31:0]	 	exe_alu_result_loc;
wire [31:0]		exe_addr_src_loc;
wire[31:0]		exe_addr_loc;
wire 					brnch_takenn_loc;
//forwarding
assign alu_src1 = (exe_bp_in[`M2E_SRC1_MUX])?(exe_bp_in[`W2E_SRC1_MUX]?exe_src1_in:exe_result_frm_w):(exe_result_frm_m);
assign alu_src2 = (exe_bp_in[`M2E_SRC2_MUX])?(exe_bp_in[`W2E_SRC2_MUX]?exe_src1_in:exe_result_frm_w):(exe_result_frm_m);
assign src1_or_imm = (exe_mux_bus_in[`SRC1_IMM_MUX])?exe_src1_in:alu_src1;
assign src2_or_pc =  (exe_mux_bus_in[`SRC2_PC_MUX])?alu_src2:exe_pc_in;
//
core_alu core_alu(
	.src1(src1_or_imm),
	.src2(src2_or_pc),
	.alu_op(exe_alu_op_in),
	.brnch_cnd(exe_alu_cnd_in),
	.alu_result(exe_alu_result_loc),
	.brnch_takenn(brnch_takenn_loc)		
	);
//
assign exe_addr_src_loc = (exe_mux_bus_in[`PC_MUX3_MUX])?(exe_pc_in):((exe_mux_bus_in[`PC_4_SRC1_MUX])?(exe_src1_in):(exe_pc_4_in));
assign exe_addr_loc = exe_sx_imm_in + exe_addr_src_loc;

always @(posedge clk) begin 
	if(exe_enb)begin
		exe_we_reg_file_out_reg <= exe_we_reg_file_in;
		exe_wb_sx_op_out_reg <= exe_wb_sx_op_in;
		exe_l1d_size_out_reg <= exe_l1d_size_in;
		exe_l1d_val_out_reg <= exe_l1d_val_in;
		exe_l1d_cop_out_reg <= exe_l1d_cop_in;
		exe_mux_alu_mem_out_reg <=	exe_mux_bus_in[`ALU_MEM_MUX];
		exe_mux_trn_out_reg <= exe_s_frm_haz_mux_trn_in;
		exe_alu_result_out_reg <= exe_alu_result_loc;
		exe_w_data_out_reg <= exe_src2_in;
		exe_sx_imm_out_reg <= exe_sx_imm_in;
		exe_pc_4_out_reg <= exe_pc_4_in;
		exe_addr_out_reg <= exe_addr_loc;
		exe_rs1_out_reg <= exe_rs1_in;
		exe_rs2_out_reg <= exe_rs2_in;
		exe_rd_out_reg <= exe_rd_in;
		exe_haz_cmd_out_reg <= exe_haz_cmd_in;
		exe_wrt_data_out_reg <= exe_src2_in;
		exe_val_inst_out_reg <= exe_val_inst_in;
	end	
	if(exe_kill) begin
		exe_alu_result_out_reg <= 0;
		exe_l1d_cop_out_reg <= 0;
		exe_l1d_val_out_reg <=0;
		exe_l1d_size_out_reg <= 0;
		exe_sx_imm_out_reg <= 0;
		exe_pc_4_out_reg <= 0;
		exe_w_data_out_reg <= 0;
		exe_addr_out_reg <= 0;
		exe_mux_alu_mem_out_reg <= 1'b0;
		exe_we_reg_file_out_reg <= 1'b0;
		exe_wb_sx_op_out_reg <= `WB_SX_BP;
		exe_mux_trn_out_reg <= 0;
		exe_rs1_out_reg <= 0;
		exe_rs2_out_reg <=0;
		exe_rd_out_reg <=0;
		exe_haz_cmd_out_reg <=0;
		exe_wrt_data_out_reg<=0;
		exe_val_inst_out_reg<=0;
	end	
end
assign exe2haz_brnch_tknn_out = brnch_takenn_loc;
assign exe2haz_we_reg_file_out = exe_we_reg_file_in;
assign exe2haz_rs1_out = exe_rs1_in;
assign exe2haz_rs2_out = exe_rs2_in;
assign exe2haz_rd_out = exe_rd_in;
assign exe2haz_cmd = exe_haz_cmd_in;
endmodule		  