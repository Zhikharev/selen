// ----------------------------------------------------------------------------
// FILE NAME          :core_pipeline.sv
// PROJECT              :Selen
// AUTHOR              :Alexsandr Bolotnokov
// AUTHOR'S EMAIL	:AlexsandrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION      :connection bwtwine all modules of stage and
//                            hazard controll
// ----------------------------------------------------------------------------
//include core_defines.vh;
module core_pipeline
	(
		input 					clk,
		input  					rst_n,

		input 	[31:0] 	csr_nc_base,
		input 	[31:0]  csr_nc_mask,

		// l1i
		input[31:0]			pl_l1i_ack_rdata,
		input 					pl_l1i_ack,
		output 					pl_l1i_req_val,
		output	[31:0]	pl_l1i_req_addr,

	//l1d
		output					pl_l1d_req_val,
		output 	[31:0] 	pl_l1d_req_addr,
		output 	[2:0] 	pl_l1d_req_cop,
		output  [31:0] 	pl_l1d_req_wdata,
		output 	[2:0]		pl_l1d_req_size,
		input 					pl_l1d_ack_ack,
		input 	[31:0]	pl_l1d_ack_rdata,
	//val_inst
		output 					pl_val_inst
	);
//hazard wires
wire[2:0] 	haz_kill_bus_loc;
wire[3:0]		haz_enb_bus_loc;
wire 				haz2exe_s_mux_trn_out;
wire[3:0]		haz2exe_bp_mux_exe;
wire 				haz2mem_bp_mux_mem;
wire[1:0]		dec2haz_cmd;
wire 				dec2haz_stall;				
wire 				mem2haz_we_reg_file;
//
wire[4:0]		exe2haz_rs1;
wire[4:0]		exe2haz_rs2;
wire[4:0]		exe2haz_rd;
wire 				exe2haz_brnch_tknn;
wire[1:0]		exe2haz_cmd;
wire 				exe2haz_we_reg_file;
wire 				wb2haz_stall;
wire[4:0]		mem2haz_rs1;
wire[4:0]		mem2haz_rs2;
wire[4:0]		mem2haz_rd;
wire[1:0]		mem2haz_cmd;
// from  or 2 if
wire 				exe2if_mux_trn_s;
wire[31:0]	exe2if_addr;
wire[31:0]	if2dec_pc;
wire[31:0]	if2dec_pc_4;
//
//decode's wire
wire[31:0]	wb2dec_wrt_data;
wire 				wb2dec_we_reg_file;
wire[2:0] dec2exe_wb_sx_op;
wire[5:0] dec2exe_mux_bus; 
wire 			dec2exe_we_reg_file;
wire[3:0]	dec2exe_alu_op;
wire[2:0]	dec2exe_alu_cnd;
wire[1:0]	dec2exe_hazard_cmd;
//
wire 			dec2exe_l1i_req_val;
wire 			dec2exe_l1i_req_cop;
wire[2:0]	dec2exe_l1i_req_size;
//
//
wire[31:0] 	dec2exe_src1;
wire[31:0]	dec2exe_src2;
wire[31:0]	dec2exe_sx_imm;
wire[31:0] 	dec2exe_pc;
wire[31:0]  dec2exe_pc_4;
wire[4:0]		dec2exe_rs1;
wire[4:0]		dec2exe_rs2;
wire[4:0]		dec2exe_rd;

wire[31:0] 	mem2exe_bp_data;
wire[31:0]	wb2exe_bp_data;
assign 			wb2exe_bp_data = wb2dec_wrt_data;
wire[2:0] 	exe2mem_wb_sx_op;
wire				exe2mem_l1d_cop;
wire[2:0]		exe2mem_l1d_size;
wire 				exe2mem_l1d_val;
wire 				exe2mem_we_reg_file;
wire 				exe2mem_mux_alu_mem;
wire[31:0]	exe2mem_wrt_data;
//
wire[31:0]	exe2mem_alu_result;
wire[31:0]	exe2mem_sx_imm;
wire[31:0]	exe2mem_pc_4;
wire[31:0]	exe2mem_w_data;
wire[31:0]	exe2mem_addr;
//
wire[4:0]		exe2mem_rs1;
wire[4:0]		exe2mem_rs2;
wire[4:0]		exe2mem_rd;
wire[1:0]		exe2mem_haz_cmd;
// mem's wire
wire[31:0]	mem2wb_sx_imm;
wire[31:0]	mem2wb_alu_result;
wire[31:0] 	mem2wb_pc_4;	 
wire 				mem2wb_mux_alu_mem;
wire 				mem2wb_we_reg_file;
wire[2:0]		mem2wb_wb_sx_op;
wire[4:0] 	mem2wb_rd;
wire[1:0]  	mem2wb_haz_cmd;
///validation of instruction
wire 	dec2exe_val_instr;
wire 	exe2mem_val_instr;
///
wire[4:0]	wb2haz2dec_rd;
wire[1:0]	wb2haz_cmd;
wire if2dec_start;
core_if_s core_if_s (
.clk(clk),
.rst_n(rst_n),
//register control
.if_kill(haz_kill_bus_loc[`REG_IF_DEC]),
.if_enb(haz_enb_bus_loc[`REG_IF_DEC]),
//from hazard control
.if_mux_trn_s_in(exe2if_mux_trn_s),
// for transfer of address
.if_addr_mux_trn_in(exe2if_addr),
//for l1i $
.if_addr_l1i_cash_out(pl_l1i_req_addr),
.if_val_l1i_cahe_out(pl_l1i_req_val),//global
//register if/dec
.if_pc_reg_out(if2dec_pc),
.if_pc_4_reg_out(if2dec_pc_4),
.if_start_out_reg(if2dec_start)
);
core_dec_s core_dec_s(
.dec_start_in(if2dec_start),
.clk(clk),
.rst_n(rst_n),
.dec_enb(haz_enb_bus_loc[`REG_DEC_EXE]),
.dec_kill(haz_kill_bus_loc[`REG_DEC_EXE]),
//inside terminals
.dec_inst_in(pl_l1i_ack_rdata),//global l1i
.dec_data_wrt_in(wb2dec_wrt_data),
.dec_l1i_ack_in(pl_l1i_ack),//global l1i
.dec_we_reg_file_in(wb2dec_we_reg_file),
//. form if station
.dec_pc_in(if2dec_pc),
.dec_pc_4_in(if2dec_pc_4),
// 2 exe station
//control pins
.dec_wb_sx_op_out_reg(dec2exe_wb_sx_op),
.dec_mux_bus_out_reg(dec2exe_mux_bus),
.dec_we_reg_file_out_reg(dec2exe_we_reg_file),
.dec_alu_op_out_reg(dec2exe_alu_op),
.dec_alu_cnd_out_reg(dec2exe_alu_cnd),
.dec_hazard_cmd_out_reg(dec2exe_hazard_cmd),
//cash
.dec_l1d_req_val_out_reg(dec2exe_l1i_req_val),
.dec_l1d_req_cop_out_reg(dec2exe_l1i_req_cop),
.dec_l1d_req_size_out_reg(dec2exe_l1i_req_size),
//information pins
.dec_src1_out_reg(dec2exe_src1),
.dec_src2_out_reg(dec2exe_src2),
.dec_sx_imm_out_reg(dec2exe_sx_imm),
.dec_pc_out_reg(dec2exe_pc),
.dec_pc_4_out_reg(dec2exe_pc_4),
.dec_rs1_out_reg(dec2exe_rs1),
.dec_rs2_out_reg(dec2exe_rs2),
.dec_rd_out_reg(dec2exe_rd),
// for hazard 
.dec2haz_cmd_out(dec2haz_cmd),
.dec_stall_out(dec2haz_stall),

.dec_val_inst_out_reg(dec2exe_val_instr),
.dec_rd_reg_file_in(wb2haz2dec_rd)
);

core_exe_s core_exe_s( 
.exe_val_inst_in(dec2exe_val_instr),
//
.clk(clk),
.exe_kill(haz_kill_bus_loc[`REG_EXE_MEM]),
.exe_enb(haz_enb_bus_loc[`REG_EXE_MEM]),
//
.exe_s_frm_haz_mux_trn_in(haz2exe_s_mux_trn_out),
//fromdeceode
//controlpins
.exe_we_reg_file_in(dec2exe_we_reg_file),
.exe_wb_sx_op_in(dec2exe_wb_sx_op),
.exe_mux_bus_in(dec2exe_mux_bus),
.exe_alu_op_in(dec2exe_alu_op),
.exe_alu_cnd_in(dec2exe_alu_cnd),
//cash
.exe_l1d_val_in(dec2exe_l1i_req_val),
.exe_l1d_size_in(dec2exe_l1i_req_size),
.exe_l1d_cop_in(dec2exe_l1i_req_cop),
//informationpins
.exe_src1_in(dec2exe_src1),
.exe_src2_in(dec2exe_src2),
.exe_pc_in(dec2exe_pc),
.exe_pc_4_in(dec2exe_pc_4),
.exe_sx_imm_in(dec2exe_sx_imm),
//forhazard
.exe_rs1_in(dec2exe_rs1),
.exe_rs2_in(dec2exe_rs2),
.exe_rd_in(dec2exe_rd),
.exe_result_frm_m(mem2exe_bp_data),
.exe_result_frm_w(wb2exe_bp_data),
.exe_bp_in(haz2exe_bp_mux_exe),
.exe_haz_cmd_in(dec2exe_hazard_cmd),
//tomemmory
.exe_wb_sx_op_out_reg(exe2mem_wb_sx_op),
.exe_l1d_cop_out_reg(exe2mem_l1d_cop),
.exe_l1d_val_out_reg(exe2mem_l1d_val),
.exe_l1d_size_out_reg(exe2mem_l1d_size),
.exe_we_reg_file_out_reg(exe2mem_we_reg_file),
.exe_mux_alu_mem_out_reg(exe2mem_mux_alu_mem),
//exe/memister

.exe_alu_result_out_reg(exe2mem_alu_result),
.exe_sx_imm_out_reg(exe2mem_sx_imm),
.exe_pc_4_out_reg(exe2mem_pc_4),
.exe_w_data_out_reg(exe2mem_w_data),
.exe_addr_out_reg(exe2if_addr),
.exe_mux_trn_out_reg(exe2if_mux_trn_s),
.exe_wrt_data_out_reg(exe2mem_wrt_data),
//
.exe_rs1_out_reg(exe2mem_rs1),
.exe_rs2_out_reg(exe2mem_rs2),
.exe_rd_out_reg(exe2mem_rd),
.exe_haz_cmd_out_reg(exe2mem_haz_cmd),
//inner pins
.exe2haz_brnch_tknn_out(exe2haz_brnch_tknn), 				
.exe2haz_we_reg_file_out(exe2haz_we_reg_file),
.exe2haz_rs1_out(exe2haz_rs1),
.exe2haz_rs2_out(exe2haz_rs2),
.exe2haz_rd_out(exe2haz_rd),
.exe2haz_cmd_out(exe2haz_cmd),
//
.exe_val_inst_out_reg(exe2mem_val_instr)
);
core_mem_s core_mem_s(
.mem_val_inst_in(exe2mem_val_instr),

.clk(clk),
.mem_enb(haz_enb_bus_loc[`REG_MEM_WB]),
//controlpins
.mem_wb_sx_op_in(exe2mem_wb_sx_op),
.mem_l1d_req_val_in(exe2mem_l1d_val),
.mem_l1d_req_cop_in(exe2mem_l1d_cop),
.mem_l1d_req_size_in(exe2mem_l1d_size),
.mem_we_reg_file_in(exe2mem_we_reg_file),
.mem_mux_alu_mem_in(exe2mem_mux_alu_mem),
//
.mem_csr_nc_mask_in(csr_nc_mask),//cashebleoruncashble
.mem_csr_nc_base_in(csr_nc_base),
//datapins
.mem_alu_result_in(exe2mem_alu_result),
.mem_sx_imm_in(exe2mem_sx_imm),
.mem_pc_4_in(exe2mem_pc_4),
.mem_wrt_data_in(exe2mem_wrt_data),
.mem_addr_in(exe2mem_addr),
//hazards
.mem_haz_cmd_in(exe2mem_haz_cmd),
.mem_bp_mux_in(haz2mem_bp_mux_mem),
.mem_bp_from_wb_data_in(wb2dec_wrt_data),
.mem_rs1_in(exe2mem_rs1),
.mem_rs2_in(exe2mem_rs2),
.mem_rd_in(exe2mem_rd),
//l1d bus
.mem2l1d_req_val_out(pl_l1d_req_val),//global
.mem2l1d_req_size_out(pl_l1d_req_size),//global
.mem2l1d_req_cop_out(pl_l1d_req_cop),//global
.mem2l1d_wrt_data_mem_out(pl_l1d_req_wdata),//global
.mem2l1d_addr_out(pl_l1d_req_addr),//global
//
.mem2exe_bp_data_out(mem2exe_bp_data),
//data outs
.mem_alu_result_out_reg(mem2wb_alu_result),
.mem_sx_imm_out_reg(mem2wb_sx_imm),
.mem_pc_4_out_reg(mem2wb_pc_4),
//controlouts
.mem_mux_alu_mem_out_reg(mem2wb_mux_alu_mem),
.mem_we_reg_file_out_reg(mem2wb_we_reg_file),
.mem_wb_sx_op_out_reg(mem2wb_wb_sx_op),
//hazard
.mem_rd_out_reg(mem2wb_rd),
.mem2haz_we_reg_file_out(mem2haz_we_reg_file),
.mem2haz_rs1_out(mem2haz_rs1),
.mem2haz_rs2_out(mem2haz_rs2),
.mem2haz_rd_out(mem2haz_rd),
.mem2haz_cmd_out(mem2haz_cmd),
//
.mem_val_inst_out_reg(pl_val_inst),
.mem_haz_cmd_out_reg(mem2wb_haz_cmd)
);
core_wb_s core_wb_s(
.clk(clk),
//control
.wb_mux_alu_mem_in(mem2wb_mux_alu_mem),
.wb_ack_from_lid_in(pl_l1d_ack_ack),
.wb_we_reg_file_in(mem2wb_we_reg_file),
.wb_sx_op_in(mem2wb_wb_sx_op),
//dataterminals
.wb_alu_result_in(mem2wb_alu_result),
.wb_sx_imm_in(mem2wb_sx_imm),
.wb_pc_4_in(mem2wb_pc_4),
.wb_mem_data_in(pl_l1d_ack_rdata),
.wb_cmd_in(mem2haz_cmd),

.wb_we_reg_file_out(wb2dec_we_reg_file),
.wb_data_out(wb2dec_wrt_data),
.wb_stall_out(wb2haz_stall),
.wb2haz_rd_out(wb2haz2dec_rd),

.wb_rd_in(mem2wb_rd)
);

core_hazard_ctrl core_hazard_ctrl(.
rst_n(rst_n),
//istercontroll
.haz_enb_bus_out(haz_enb_bus_loc),
.haz_kill_bus_out(haz_kill_bus_loc),
//
.haz_mux_trn_out(haz2exe_s_mux_trn_out),
//forwarding
.haz_bp_mux_exe_out(haz2exe_bp_mux_exe),
.haz_bp_mux_mem_out(haz2mem_bp_mux_mem),
//sourses and destinations
.haz_exe_rs1_in(exe2haz_rs1),
.haz_exe_rs2_in(exe2haz_rs2),
.haz_exe_rd_in(exe2haz_rd),
.haz_mem_rs1_in(mem2haz_rs1),
.haz_mem_rs2_in(mem2haz_rs2),
.haz_mem_rd_in(mem2haz_rd),
.haz_wb_rd_in(wb2haz2dec_rd),
//we of regfile
.haz_we_reg_file_exe_s_in(exe2haz_we_reg_file),
.haz_we_reg_file_mem_s_in(mem2haz_we_reg_file),//exsessivepin
.haz_we_reg_file_wb_s_in(),
//brnch taken from alu
.haz_brnch_tknn_in(exe2haz_brnch_tknn),
//stall of cahe
.haz_stall_dec_in(dec2haz_stall),
.haz_stall_wb_in(wb2haz_stall),
//comand from each stages
.haz_cmd_dec_s_in(dec2haz_cmd),
.haz_cmd_exe_s_in(exe2haz_cmd),
.haz_cmd_mem_s_in(mem2haz_cmd),
.haz_cmd_wb_s_in(wb2haz_cmd)
);

endmodule
