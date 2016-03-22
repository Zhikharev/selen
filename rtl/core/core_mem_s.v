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
//include core_defines.vh;
module core_mem_s (
	input 						mem_val_inst_in,
	input 						clk,
	input 						rst_n,
	input							mem_enb,
	//control pins
	input[2:0]				mem_wb_sx_op_in,
	input 		 				mem_l1d_req_val_in,
	input						 	mem_l1d_req_cop_in,
	input[2:0]				mem_l1d_req_size_in,
	input							mem_we_reg_file_in,
	input							mem_mux_alu_mem_in,
	//
	input[31:0]				mem_csr_nc_mask_in,//casheble or uncashble 
	input[31:0]				mem_csr_nc_base_in,
	//data pins
	input[31:0]				mem_alu_result_in,
	input[31:0]				mem_sx_imm_in,
	input[31:0]				mem_pc_4_in,
	input[31:0]				mem_wrt_data_in,
	input[31:0]				mem_addr_in,
	//hazards 
	input[4:0]				mem_rs1_in,
	input[4:0]				mem_rs2_in,
	input[4:0]				mem_rd_in,
	input[1:0]				mem_haz_cmd_in,
	input							mem_bp_mux_in,
	input[31:0]				mem_bp_from_wb_data_in,
	
	//l1d bus
	output  					mem2l1d_req_val_out,
	output[2:0]				mem2l1d_req_size_out,
	output[2:0]				mem2l1d_req_cop_out,
	output[31:0]			mem2l1d_wrt_data_mem_out,
	output[31:0]			mem2l1d_addr_out,
	//
	output[31:0]			mem2exe_bp_data_out,
	//data outs 
	output reg[31:0]	mem_alu_result_out_reg,
	output reg[31:0]	mem_sx_imm_out_reg,
	output reg[31:0]	mem_pc_4_out_reg,
	//control outs
	output reg 				mem_mux_alu_mem_out_reg,
	output reg 			 	mem_we_reg_file_out_reg,
	output reg[2:0]	 	mem_wb_sx_op_out_reg,
	// 2 hazard 
	output reg[4:0]		mem_rd_out_reg,
	output reg[1:0]		mem_haz_cmd_out_reg,
	output 						mem2haz_we_reg_file_out,
	//
	output[4:0]				mem2haz_rs1_out,
	output[4:0]				mem2haz_rs2_out,
	output[4:0]				mem2haz_rd_out,
	output[1:0]				mem2haz_cmd_out,

	output 					mem_val_inst_out
);
wire cash_uncash;
reg mem_val_inst_out_reg;
always @(posedge clk) begin 
	if(mem_enb) begin
		mem_alu_result_out_reg <= mem_alu_result_in;
		mem_sx_imm_out_reg <= mem_sx_imm_in;
		mem_pc_4_out_reg <= mem_pc_4_in;
		mem_we_reg_file_out_reg <= 	mem_we_reg_file_in;
		mem_mux_alu_mem_out_reg <=	mem_mux_alu_mem_in;
		mem_wb_sx_op_out_reg <=	mem_wb_sx_op_in;
		mem_rd_out_reg <= mem_rd_in;
		mem_val_inst_out_reg <= mem_val_inst_in;
		mem_haz_cmd_out_reg <= mem_haz_cmd_in;
	end
end
assign mem2haz_cmd_out = mem_haz_cmd_in;
assign cash_uncash = (mem_alu_result_in &~({`ADDR_WIDTH{1'b0}} | `ADDR_MASK)) == `ADDR_BASE;
assign mem2l1d_req_cop_out = {1'b0,cash_uncash,mem_l1d_req_cop_in};
assign mem2l1d_req_val_out =  mem_l1d_req_val_in;
assign mem2l1d_req_size_out = mem_l1d_req_size_in;
assign mem2l1d_wrt_data_mem_out = (mem_bp_mux_in)?mem_bp_from_wb_data_in:mem_wrt_data_in;
assign mem2l1d_addr_out = mem_alu_result_in;
assign mem2exe_bp_data_out = mem_alu_result_in;
assign mem2haz_we_reg_file_out = mem_we_reg_file_in;
assign mem2haz_rs1_out =  mem_rs1_in;
assign mem2haz_rs2_out = mem_rs2_in;
assign mem2haz_rd_out = mem_rd_in;
assign mem_val_inst_out = mem_val_inst_out_reg & mem_enb ;
endmodule // core_mem
/*	if(mem_kill) begin
		mem_alu_result_out_reg <= 0;
		mem_sx_imm_out_reg <= 0;
		mem_pc_4_out_reg <= 0;
		mem_we_reg_file_out_reg <= 0;
		mem_mux_alu_mem_out_reg <=	0;
		mem_wb_sx_op_out_reg <=	0;
		mem_rd_out_reg <= 0;
		mem_val_inst_out_reg <=0;
	end	 */