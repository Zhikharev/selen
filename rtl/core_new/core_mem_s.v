// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            	: core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		: memory phase of pipline 
// ----------------------------------------------------------------------------
module core_mem_s (
	input 						clk,
	input 						n_rst,
	input							mem_enb,
	input							mem_kill,
	//control pins
	input[2:0]				mem_wb_sx_op_in,
	input 		 				mem_l1i_req_val_in,
	input[1:0]			 	mem_l1i_req_cop_in,
	input[2:0]				mem_l1i_req_size_in,
	input							mem_we_reg_file_in,
	input							mem_mux_alu_mem_in,
	//
	input[31:0]				mem_cahs_reg_in,//casheble or uncashble 
	//data pins
	input							mem_alu_result_in,
	input[31:0]				mem_sx_imm_in,
	input[31:0]				mem_pc_4_in,
	input[31:0]				mem_wrt_data_in,
	input[31:0]				mem_addr_in,
	//hazards 
	input[4:0]				mem_rs1_in,
	input[4:0]				mem_rs2_in,
	input[4:0]				mem_rd_in,
	input							mem_bp_mux_in,
	input[31:0]				mem_bp_from_wb_data_in,
	
	//l1d bus
	output reg 				mem2l1d_req_val_out_reg,
	output reg[2:0]		mem2l1d_req_size_out_reg,
	output reg[2:0]		mem2l1d_req_cop_out_reg,
	output reg[31:0]	mem_wrt_data_mem_out_reg,
	//
	output[31:0]			mem2exe_bp_data_out,
	//data outs 
	output reg[31:0]	mem_alu_result_reg_out,
	output reg[31:0]	mem_sx_imm_reg_out,
	output reg[31:0]	mem_pc_4_reg_out,
	//control outs
	output reg 				mem_mux_out_reg,
	output reg 			 	mem_we_reg_file_out_reg,
	output reg[2:0]	 	mem_wb_sx_op_out_reg,
	// 2 hazard 
	output reg[4:0]		mem_rd_out_reg,
	output 						mem2haz_we_reg_file_out,
	//
	output[4:0]				mem2haz_rs1,
	output[4:0]				mem2haz_rs2,
	output[4:0]				mem2haz_rd
);
include core_defines.vh;
wire cash_ucash;
always @(posedge clk) begin 
	if(mem_enb) begin
		mem_alu_result_reg_out <= mem_alu_result_in;
		mem_sx_imm_reg_out <= 	mem_sx_imm_in;
		mem_pc_4_reg_out <= 		mem_pc_4_in;
		mem_we_reg_file_out_reg <= 	mem_we_reg_file_in;
		mem_mux_out_reg <=		mem_mux_alu_mem_in;
		mem_wb_sx_op_out_reg <=	mem_wb_sx_op_in;
		mem_rd_out_reg <= mem_rd_in;
		mem2l1d_req_val_out_reg <= mem_l1i_req_val_in;
		mem2l1d_req_cop_out_reg <= {1'b0,cash_ucash,mem_l1i_req_cop_in};
		mem2l1d_req_size_out_reg <= mem_l1i_req_size_in;
		mem_wrt_data_mem_out_reg <= mem_wrt_data_in;
	end
	if(mem_kill) begin
		mem_alu_result_reg_out <= 	0;
		mem_sx_imm_reg_out <= 		0;
		mem_pc_4_reg_out <= 		0;
		mem_we_reg_file_out_reg <= 	0;
		mem_mux_out_reg <=			0;
		mem_wb_sx_op_out_reg <=	0;
		mem_rd_out_reg <= 0;
		mem2l1d_req_val_out_reg <= 0;
		mem2l1d_req_cop_out_reg <= 0;
		mem2l1d_req_size_out_reg <= 0;
		mem_wrt_data_mem_out_reg <=0;
	end	 
end
assign mem_wrt_data_in = (mem_bp_mux_in)?mem_bp_from_wb_data_in:mem_wrt_data_in;
assign cash_ucash = (mem_alu_result_in > mem_cahs_reg_in)? `CASHABLE:`UNCASHABLE;
assign mem2exe_bp_data_out = mem_alu_result_in;
assign mem2haz_we_reg_file_out = mem_we_reg_file_in;
assign mem2haz_rs1 =  mem_rs1_in;
assign mem2haz_rs2 = mem_rs2_in;
assign mem2haz_rd = mem_rd_in;
endmodule // core_mem
