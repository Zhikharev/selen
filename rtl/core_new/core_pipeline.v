// ----------------------------------------------------------------------------
// FILE NAME            	: core_pipeline.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		: connection bwtwine all modules of stage and
//                          hazard controll
// ----------------------------------------------------------------------------
module core_pipeline
	(
		input 					clk,
		input  					rst_n,

		input 	[31:0] 	csr_nc_base,
		input 	[31:0]  csr_nc_mask,

		// l1i
		input[	31:0]		pl_l1i_ack_rdata,
		input 					pl_l1i_ack,
		output 					pl_l1i_req_val,
		output	[31:0]	pl_l1i_req_aadr,

	//l1d
		output					pl_l1d_req_val,
		output 	[31:0] 	pl_l1d_req_addr,
		output 	[2:0] 	pl_l1d_req_cop,
		output  [31:0] 	pl_l1d_req_wdata,
		output 	[2:0]		pl_l1d_req_size,
		input 					pl_l1d_ack_ack,
		input 	[31:0]	pl_l1d_ack_rdata
	);

core_if_s (
.clk(),
.n_rst(),
//register control
.if_kill(),
.if_enb(),
//from hazard control
.if_pc_stop_in(),
.if_mux_trn_s_in(),
// for transfer of address
.if_addr_mux_trn_in(),
//for l1i $
.if_addr_l1i_cash_out(),
.if_val_l1i_cahe_out(),
//register if/dec
.if_pc_reg_out(),
.if_pc_4_reg_out()
);

core_dec_s(
.clk(),
.rst_n(),
.dec_enb(),
.dec_kill(),
//inside terminals
. dec_nop_gen_in(),
.dec_inst_in(),
.dec_data_wrt_in(),
.dec_il_ack_in(),
.dec_we_file_in(),
//. form if station
.dec_pc_in(),
.dec_pc_in(),
//  exe station
//control pins
.dec_wb_sx_op_out_reg(),
.dec_ld_out_reg(),
.dec_mux_bus_out_reg(),
.dec_we_file_out_reg(),
.dec_alu_op_out_reg(),
.dec_alu_cnd_out_reg(),
//information pins
.dec_src_out_reg(),
.dec_src_out_reg(),
.dec_sx_imm_out_reg(),
.dec_pc_out_reg(),
.dec_pc__out_reg(),
// for hazard 
.dec_hazard_bus_out_reg(),
.dec_hazard_cmd_out_reg(),
.dec_stall_out()
);

core_exe_s(
.clk(),
.rst_n(),
.exe_enb(),
.exe_kill(),
//
.exe_s_frm_haz_mux_trn_in(),
//fromdeceode
//controlpins
.exe_we_file_in(),
.exe_wb_sx_op_in(),
.exe_ld_bus_in(),
.exe_mux_bus_in(),
.exe_alu_op_in(),
.exe_alu_cnd_in(),
//informationpins
.exe_src_in(),
.exe_src_in(),
.exe_pc_in(),
.exe_pc_in(),
.exe_sx_imm_in(),
//forhazard
.exe_hazrd_bus_in(),
.exe_result_frm_m(),
.exe_result_frm_w(),
.exe_bp_in(),
//tomemmory
.exe_wb_sx_op_out_reg(),
.exe_ld_bus_out_reg(),
.exe_we_file_out_reg(),
.exe_mux_alu_mem_out_reg(),
//exe/memister
.exe_alu_result_out_reg(),
.exe_sx_imm_out_reg(),
.exe_pc__out_reg(),
.exe_w_data_out_reg(),
.exe_addr_out_reg(),
.exe_mux_trn_out_reg(),
//innerpins
.exehaz_brnch_tknn(),
.exehaz_we_file_out()
);

core_mem_s(
.clk(),
.rst_n(),
.mem_enb(),
.mem_kill(),
//controlpins
.mem_wb_sx_op_in(),
.mem_ld_bus_in(),
.mem_we__file_in(),
.mem_mux_alu_mem_in(),
//
.mem_cahs_in(),//cashebleoruncashble
//datapins
.mem_alu_result_in(),
.mem_sx_imm_in(),
.mem_pc_in(),
.mem_wrt_data_in(),
.mem_addr_in(),
//hazards
.mem_hazrd_bus_in(),
.mem_bp_mux_in(),
.mem_bp_from_wb_data_in(),
//ldbus
.memld_req_val_out_reg(),
.memld_req_size_out_reg(),
.memld_req_cop_out_reg(),
.mem_wrt_data_mem_out_reg(),
//
.memexe_bp_data_out(),
//dataouts
.mem_alu_result_out(),
.mem_sx_imm_out(),
.mem_pc_out(),
//controlouts
.mem_mux_out_reg(),
.mem_we__file_out_reg(),
.mem_wb_sx_op_out_reg(),
//hazard
.mem_rd_out_reg(),
.memhaz_we_file_out()
);

core_wb_s(
.clk(),
.rst_n(),
//control
.wb_mux_in(),
.wb_ack_from_lid_in(),
.wb_we__file_in(),
.wb_sx_op_in(),
//dataterminals
.wb_alu_result_in(),
.wb_sx_imm_in(),
.wb_pc_4_in(),
.wb_mem_data_in(),

.wb_we__file_out(),
.wb_data_out(),
.wb_stall_out()
);


endmodule
