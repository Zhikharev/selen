module core_pipline(
	input 						clk,
	input  						rst_n,

	// l1i

	input[31:0]				pl_l1i_ack_rdata_in,
	input 						pl_l1i_ack_in,
	output 						pl_l1i_req_val_out,
	output[31:0]			pl_l1i_req_aadr_out,
	
	//l1d

	output						pl_l1d_req_val_out,
	output[31:0] 			pl_l1d_req_addr_out,
	output[2:0] 			pl_l1d_req_cop_out,
	output[31:0] 			pl_l1d_req_wdata_out,
	output[2:0]				pl_l1d_req_size_out,
	input 						pl_l1d_ack_ack_in,
	input[31:0]				pl_l1d_ack_rdata_in
);
// if 2 dec wires
wire[31:0]	if2dec_pc_loc;
wire[31:0]	if2dec_pc_4_loc;
//decode 2 exe wires
wire[6:0]		dec2exe_l1d_bus_loc;
wire[2:0]		dec2exe_wb_sx_op_loc;
wire[5:0] 	dec2exe_mux_bus_loc;
wire[14:0]	dec2exe_haz_bus_loc;
wire[2:0]		dec2exe_alu_cnd_loc;
wire[3:0]		dec2exe_alu_op_loc;
wire[31:0]	dec2exe_src1_loc;
wire[31:0]	dec2exe_src2_loc;
wire[31:0]	dec2exe_pc_loc;
wire[31:0]	dec2exe_pc_4_loc;
wire[31:0]	dec2exe_sx_imm_loc;
wire 				dec2exe_we_reg_file_loc;		
// wires from exe to memmory
wire[31:0] 	exe2mem_alu_result_loc;
wire[31:0]	exe2mem_sx_imm_loc;
wire[31:0]	exe2mem_wdata_loc;
wire[31:0]	exe2mem_pc_4_loc;
wire[31:0]	exe2mem_addr_loc;
wire[31:0]	exe2mem_l1d_bus_loc;
wire 				exe2mem_mux_alu_mem_loc;
wire[14:0]	exe2mem_haz_bus;
wire 				exe2mem_we_reg_file_loc;
wire[2:0] 	exe2mem_wb_sx_cmnd;
core_if_s if_s (
	.clk(clk), 
	.rst_n(rst_n), 
	//register ctrl
	.if_enb(), 
	.if_kill(), 
	//from haz	
	.if_mux1_trn_pc_4_s(),// select signsl for mux chousing next pc source
	.if_pc_stop(),// stop counting for pc 
	//
	.if_mux1_addr(),// adrress for branch or jump 
	.if_val(),// actuality of request to livel 1 instruction cash
	.if_lid_pc_out_reg(),// pc output from fetch/ decode register 
	// to decode
	.if_pc(),
	.if_pc_4(),//pc_4 output from fetch/ decode register  				
);

cpu_dec_s(
.clk(clk),//system clock
.rst_n(rst_n),//system reset
// cntrl 
.dec_enb(),
.dec_kill(),// clear decode/execution ister
//inside terminals
.dec_nop_gen_in(),//
.dec_inst_in(pl_l1i_ack_rdata_in),//global //instruction from level 1 instruction cashe
.dec_data_wrt_in(),
.dec_il1_ack_in(pl_l1i_ack_in),//global// acknowlegment from level 1 instruction cashe
.dec_we_file_in(),// write enable for ister file
// 2 exe station
.dec_wb_sx_op_out_(dec2exe_wb_sx_op_loc),
.dec_we_file_out_(dec2exe_we_reg_file_loc),
.dec_src1_out_(dec2exe_src1_loc),
.dec_src2_out_(dec2exe_src2_loc),
.dec_pc_out_(if2dec_pc_loc),
.dec_pc_4_out_(if2dec_pc_4_loc),
.dec_sx_imm_out_(dec2exe_sx_imm_loc),
.dec_ld1_out_(dec2exe_l1d_bus_loc),// consistes of the MSB is validation of request(), then 1'b0 is rezerved after  
//the nex 2 bits are  casheble or uncasheble and read or write respectively the last 3 bits mean size of request to mem
.dec_mux_bus_out_(dec2exe_mux_bus_loc),
.dec_alu_op_out_(dec2exe_alu_op_loc),
.dec_alu_cnd_out_(dec2exe_alu_cnd_loc),// the MSB equals 1 means there is a branch command
.dec_hazard_bus_out_(dec2exe_haz_bus_loc),
// for hazard 
.dec_hazard_type_out_(),// signals to hazard
.dec_stall_out()// signal detecting absent of data from cashe
);

core_exe_s	exe_s(
.clk(clk),
.rst_n(rst_n),

.exe_enb(),
.exe_kill(),
//fromdeceode
.exe_src1_in(dec2exe_src1_loc),
.exe_src2_in(dec2exe_src2_loc),
.exe_pc_in(dec2exe_pc_loc),
.exe_pc_4_in(dec2exe_pc_4_loc),
.exe_sx_imm_in(dec2exe_sx_imm_loc),

.exe_mux_bus_in(dec2exe_mux_bus_loc),
.exe_l1d_bus_in(dec2exe_l1d_bus_loc),
.exe_hazrd_bus_in(dec2exe_haz_bus_loc),
.exe_alu_op_in(dec2exe_alu_op_loc),
.exe_alu_cnd_in(dec2exe_alu_cnd_loc),
.exe_we_reg_file_in(dec2exe_we_reg_file_loc),
.exe_wb_sx_op_in(dec2exe_wb_sx_op_loc),

.exe_result_frm_m(),
.exe_result_frm_w(),
.exe_bp_in(),
//tomemmory
.regexe_wb_sx_op_out_reg(),
.regexe_l1d_bus_out_reg(),
.regexe_we_reg_file_out_reg(),
.regexe_mux_out_reg(),

.regexe_alu_result_out_reg(),
.regexe_sx_imm_out_reg(),
.regexe_pc_4_out_reg(),
.regexe_w_data_out_reg(),
.regexe_addr_out_reg(),
.regexe_brnch_takenn_out_reg
);

core_mem_s mem_s (
.clk(clk),
.rst_n(rst_n),
.mem_enb(),
.mem_kill(),

.mem_ld1_bus_in(exe2mem_l1d_bus_loc),
.mem_cahs_reg_in(),//global //casheble or uncashble 
.mem_mux_in(exe2mem_mux_alu_mem_loc),
.mem_we_reg_file_in(exe2mem_we_reg_file_loc),
.mem_alu_result_in(exe2mem_alu_result_loc),
.mem_brnch_takenn_in(),
.mem_wrt_data_in(exe2mem_wdata_loc),
.mem_sx_imm_in(exe2mem_sx_imm_loc),
.mem_pc_4_in(exe2mem_pc_4_loc),
.mem_addr_in(exe2mem_addr_loc),
.mem_wb_sx_in(exe2mem_wb_sx_cmnd),
.mem_hazrd_bus_in(exe2mem_haz_bus),

.mem_bp_mux_in(),

.mem_ld1_bus_out(),
.mem_wrt_data_.mem_out(),

.mem_alu_result_reg_out(),
.mem_sx_imm_reg_out(),
.mem_pc_4_reg_out(),
.mem_we_reg_file_out_reg(),
.mem_mux_out_reg(),
.mem_wb_sx_type_out_reg(),
.mem_rd_out_reg
);
