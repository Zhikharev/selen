// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME         		  : core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		: execution phase of pipline 
// ----------------------------------------------------------------------------
module core_exe_s (
	input						clk,
	input						rst_n, 

	input						exe_enb,
	input 						exe_kill,
	// from deceode 
	input						exe_s_frm_haz_mux_trn_in,

	input[31:0] 				exe_src1_in,
	input[31:0]					exe_src2_in,
	input[31:0]					exe_pc_in,
	input[31:0]					exe_pc_4_in,
	input[31:0]					exe_sx_imm_in,
		
	input[5:0]					exe_mux_bus_in,
	input[6:0]					exe_l1d_bus_in,
	input[14:0]					exe_hazrd_bus_in,
	input[3:0] 					exe_alu_op_in,
	input[2:0]					exe_alu_cnd_in,
	input 						exe_we_reg_file_in,
	input[2:0]					exe_wb_sx_op_in,

	input[31:0]					exe_result_frm_m,
	input[31:0]					exe_result_frm_w,
	input[3:0]					exe_bp_in,
 	// to memmory
	output reg [2:0]		 	exe_wb_sx_op_out_reg,
	output reg [6:0]		 	exe_l1d_bus_out_reg,
	output 	reg 				exe_we_reg_file_out_reg,
	output 	reg 				exe_mux_alu_mem_out_reg,

	output reg [31:0]			exe_alu_result_out_reg,
	output reg [31:0]	 		exe_sx_imm_out_reg,
	output reg [31:0]			exe_pc_4_out_reg,
	output reg [31:0]	 		exe_w_data_out_reg,
	output reg [31:0]	 		exe_addr_out_reg,
	output reg				 	exe_mux_trn_out_reg,
	output						exe2haz_brnch_tknn 				
);
wire[31:0] 		alu_src1;
wire[31:0] 		alu_src2;
wire[31:0] 		src1_or_imm;
wire[31:0]	 	src2_or_pc;
wire[31:0]	 	exe_alu_result_loc;
wire [31:0]		exe_addr_src_loc;
wire[31:0]		exe_addr_loc;
wire 			brnch_takenn_loc;
assign alu_src1 = (exe_bp_in[`M2E_SRC1_MUX])?(exe_bp_in[`W2E_SRC1_MUX]?exe_src1_in:exe_result_frm_w):(exe_result_frm_m);
assign alu_src2 = (exe_bp_in[`M2E_SRC2_MUX])?(exe_bp_in[`W2E_SRC2_MUX]?exe_src1_in:exe_result_frm_w):(exe_result_frm_m);
assign src1_or_imm = (exe_mux_bus_in[`SRC1_IMM_MUX])?exe_src1_in:alu_src1;
assign src2_or_pc =  (exe_mux_bus_in[`SRC2_PC_MUX])?alu_src2:exe_pc_in;

core_alu core_alu(
	.src1(src1_or_imm),
	.src2(src2_or_pc),
	.alu_op(exe_alu_op_in),
	.brnch_cnd(exe_alu_cnd_in),
	.alu_result(exe_alu_result_loc),
	.brnch_takenn(brnch_takenn_loc)		
	);
assign exe_addr_src_oc = (exe_mux_bus_in[`PC_MUX3_MUX])?(exe_pc_in):((exe_mux_bus_in[`PC_4_SRC1_MUX])?(exe_src1_in):(exe_pc_4_in));
assign exe_addr_loc = exe_sx_imm_in + exe_addr_src_oc;
always @(posedge clk) begin 
	if(exe_enb)begin
		exe_alu_result_out_reg <= exe_alu_result_loc;
		exe_sx_imm_out_reg <= exe_sx_imm_in;
		exe_pc_4_out_reg <= exe_pc_4_in;
		exe_w_data_out_reg <= exe_src2_in;
		exe_addr_out_reg <= exe_addr_loc;
		exe_l1d_bus_out_reg <= exe_l1d_bus_in;
		exe_mux_alu_mem_out_reg <=	exe_mux_bus_in[`ALU_MEM_MUX];
		exe_we_reg_file_out_reg <= exe_we_reg_file_in;
		exe_wb_sx_op_out_reg <= exe_wb_sx_op_in;
		exe_mux_trn_out_reg <= (exe_s_frm_haz_mux_trn_in | brnch_takenn_loc);
	end	
	if(exe_kill) begin
		exe_alu_result_out_reg <= 0;
		exe_sx_imm_out_reg <= 0;
		exe_pc_4_out_reg <= 0;
		exe_w_data_out_reg <= 0;
		exe_addr_out_reg <= 0;
		exe_l1d_bus_out_reg <= `NOT_REQ;
		exe_mux_alu_mem_out_reg <= 1'b0;
		exe_we_reg_file_out_reg <= 1'b0;
		exe_wb_sx_op_out_reg <= `WB_SX_BP;
		exe_mux_trn_out_reg <= 0;
	end	
end
assign exe2haz_brnch_tknn = brnch_takenn_loc;
endmodule		  