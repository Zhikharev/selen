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
include core_defines.vh;
//hazard wires
wire[3:0] 	haz_kill_bus_loc;
wire[3:0]		haz_enb_bus_loc;
wire 				haz2if_s_pc_stop;
wire 				haz2exe_s_mux_trn_out;
wire 				haz2dec_s_nop_gen;
wire[3:0]		haz2exe_bp_mux_exe;
wire 				haz2mem_bp_mux_mem;
wire[4:0]		wb2haz_rd;
core_if_s core_if_s (
.clk(clk),
.n_rst(n_rst),
//register control
.if_kill(haz_kill_bus_loc[`REG_IF_DEC]),
.if_enb(haz_enb_bus_loc[`REG_IF_DEC]),
//from hazard control
.if_pc_stop_in(haz2if_s_pc_stop),
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

core_dec_s core_dec_s(
.clk(clk),
.rst_n(n_rst),
.dec_enb(haz_enb_bus_out[`REG_DEC_EXE]),
.dec_kill(haz_kill_bus_loc[`REG_DEC_EXE]),
//inside terminals
.dec_nop_gen_in(haz2dec_s_nop_gen),
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
.dec_hazard_cmd_out_reg(),
//cash
.dec_l1i_req_val_out_reg(),
.dec_l1i_req_cop_out_reg(),
.dec_l1i_req_size_out_reg(),
//information pins
.dec_src_out_reg(),
.dec_src_out_reg(),
.dec_sx_imm_out_reg(),
.dec_pc_out_reg(),
.dec_pc_4_out_reg(),
.dec_rs1_out_reg(),
.dec_rs2_out_reg(),
.dec_rd_out_reg(),
// for hazard 
.dec2haz_cmd_out(),
.dec_stall_out()
);

core_exe_s core_exe_s( 
.clk(clk),
.rst_n(n_rst),
.exe_enb(haz_enb_bus_loc[`REG_EXE_MEM]),
.exe_kill(haz_kill_bus_loc[`REG_EXE_MEM]),
//
.exe_s_frm_haz_mux_trn_in(haz2exe_s_mux_trn_out),
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
.exe_result_frm_m(),
.exe_result_frm_w(),
.exe_bp_in(haz2exe_bp_mux_exe),
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
//
.exe_rs1_out_reg(),
.exe_rs2_out_reg(),
.exe_rd_out_reg(),
//innerpins
.exe2haz_brnch_tknn(), 				
.exe2haz_we_reg_file_out(),
.exe2haz_rs1(),
.exe2haz_rs2(),
.exe2haz_rd()
);

core_mem_s core_mem_s(
.clk(clk),
.n_rst(n_rst),
.mem_enb(haz_enb_bus_loc[`REG_MEM_WB]),
.mem_kill(haz_kill_bus_loc[`REG_MEM_WB]),
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
.mem_bp_mux_in(haz2mem_bp_mux_mem),
.mem_bp_from_wb_data_in(),
.mem_rs1_in(),
.mem_rs2_in(),
.mem_rd_in(),
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
.mem2haz_rs1(),
.mem2haz_rs2(),
.mem2haz_rd(),
);

core_wb_s core_wb_s(
.clk(clk),
.n_rst(n_rst),
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

core_hazard_ctrl core_hazard_ctrl(
.rst_n(n_rst),
//istercontroll
.haz_enb_bus_out(haz_enb_bus_loc),
.haz_kill_bus_out(haz_kill_bus_loc),
//
.haz_pc_stop_out(haz2if_s_pc_stop),
.haz_nop_gen_out(haz2dec_s_nop_gen),
.haz_mux_trn_out(haz2exe_s_mux_trn_out),
//forwarding
.haz_bp_mux_exe_out(haz2exe_bp_mux_exe),
.haz_bp_mux_mem_out(haz2mem_bp_mux_mem),
//sourses and destinations
.haz_exe_rs1_in(),
.haz_exe_rs2_in(),
.haz_exe_rd_in(),
.haz_mem_rs1_in(),
.haz_mem_rs2_in(),
.haz_mem_rd_in(),
.haz_wb_rd_in(),
//we of regfile
.haz_we__file_exe_s_in(),
.haz_we__file_mem_s_in(),//exsessivepin
.haz_we__file_wb_s_in(),
//brnch taken from alu
.haz_brnch_tknn_in(),
//stall of cahe
.haz_stall_dec_in(),
.haz_stall_wb_in(),
//comand from each stages
.haz_cmd_dec_s_in(),
.haz_cmd_exe_s_in(),
.haz_cmd_mem_s_in(),
.haz_cmd_wb_s_in
);

endmodule
