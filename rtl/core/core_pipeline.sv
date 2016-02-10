// ----------------------------------------------------------------------------
// FILE NAME            	: core_pipeline.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		: connection bwtwine all modules of stage and hazard controll  
// ----------------------------------------------------------------------------
module core_pipeline(
	input 						clk,
	input  						rst_n,

	input 						pl_csr_addr_cach_uncash,	
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
wire[2:0]		dec2exe_alu_cnd_loc;
wire[3:0]		dec2exe_alu_op_loc;
wire[31:0]	dec2exe_src1_loc;
wire[31:0]	dec2exe_src2_loc;
wire[31:0]	dec2exe_pc_loc;
wire[31:0]	dec2exe_pc_4_loc;
wire[31:0]	dec2exe_sx_imm_loc;
wire 				dec2exe_we_reg_file_loc;		
wire[14:0]	dec2exe_haz_bus_loc;
// wires from exe to memmory
wire[31:0] 	exe2mem_alu_result_loc;
wire[31:0]	exe2mem_sx_imm_loc;
wire[31:0]	exe2mem_wdata_loc;
wire[31:0]	exe2mem_pc_4_loc;
wire[31:0]	exe2if_addr_loc;
wire[31:0]	exe2mem_l1d_bus_loc;
wire 				exe2mem_mux_alu_mem_loc;
wire[14:0]	exe2mem_haz_bus;
wire 				exe2mem_we_reg_file_loc;
wire[2:0] 	exe2mem_wb_sx_cmnd;
// wires for mem to wb
wire[31:0]	mem2wb_alu_result;
wire[31:0]	mem2wb_imm;
wire[31:0]	mem2wb_pc_4;
wire[2:0] 	mem2wb_sx_op;
wire 				mem2wb_mux_alu_mem;
wire 				mem2wb_we_reg_file;

wire[4:0] 	mem2wb_rd
//hazard wires 
wire[2:0]		haz2regs_enb_bus;
wire[2:0]		haz2regs_kill_bus;

wire 				haz2if_ps_stop;
wire 				haz2exe_mux_trn;

wire[3:0]		haz2exe_bp_mux;
wire 				haz2mem_bp_mux;

wire 				haz2dec_nop_gen;
wire 				dec2haz_stall;
wire[1:0] 	dec2haz_cmd; 	
wire 				mem2haz_we_reg_file;

wire[1:0] 	exe2haz_cmd;
wire[14:0]	exe2haz_reg_bus;
wire 				exe2haz_brnch_tknn;
wire 				mem2haz_we_reg_file;

wire[1:0]		mem2haz_cmd;
wire[14:0]	mem2haz_reg_bus;
wire 				mem2haz_we_reg_file;

wire[4:0]		wb2haz_rd;
wire 				wb2haz_we_reg_file;
wire 				wb2haz_stall;
wire[1:0]		wb2haz_cmd;
//
wire[31:0]	wb2dec_data_wrt;
wire 				wb2dec_we_reg_file;
core_if_s if_s (
	.clk(clk), 
	.rst_n(rst_n), 
	.if_enb(haz2regs_enb_bus[`REG_IF_DEC]), 
	.if_kill(haz2regs_kill_bus[`REG_IF_DEC]), 
	.if_mux1_trn_pc_4_s(exe2if_mux_trn),
	.if_pc_stop(haz2if_ps_stop), 
	.if_mux1_addr(exe2if_addr_loc), 
	.if_val(pl_l1i_req_val_out),//global
	.if_lid_pc_out_reg(if2dec_pc_loc), 
	.if_pc(pl_l1i_req_aadr_out),//global
	.if_pc_4(if2dec_pc_4_loc)  				
);

cpu_dec_s(
.clk(clk),//system clock
.rst_n(rst_n),//system reset
// cntrl 
.dec_enb(haz2regs_enb_bus[`REG_DEC_EXE]),
.dec_kill(haz2regs_kill_bus[`REG_DEC_EXE]),// clear decode/execution ister
//inside terminals
.dec_nop_gen_in(haz2dec_nop_gen),//
.dec_inst_in(pl_l1i_ack_rdata_in),//global //instruction from level 1 instruction cashe
.dec_data_wrt_in(wb2dec_data_wrt),
.dec_il1_ack_in(pl_l1i_ack_in),//global// acknowlegment from level 1 instruction cashe
.dec_we_file_in(wb2dec_we_reg_file),// write enable for ister file
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
.dec_hazard_cmd_out_reg(dec2haz_cmd),// signals to hazard
.dec_stall_out(dec2haz_stall)// signal detecting absent of data from cashe
);

core_exe_s	exe_s(
.clk(clk),
.rst_n(rst_n),

.exe_enb(haz2regs_enb_bus[`REG_EXE_MEM]),
.exe_kill(haz2regs_kill_bus[`REG_EXE_MEM]),
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
// forwarding
.exe_result_frm_m(mem2exe_bp_data_loc),
.exe_result_frm_w(wb2exe_bp_data_loc),
.exe_bp_in(haz2exe_bp_mux),
//to memmory
.exe_wb_sx_op_out_reg(exe2mem_wb_sx_cmnd),
.exe_l1d_bus_out_reg(exe2mem_l1d_bus_loc),
.exe_we_reg_file_out_reg(exe2mem_we_reg_file_loc),
.exe_mux_out_reg(exe2mem_mux_alu_mem_loc),

.exe_alu_result_out_reg(exe2mem_alu_result_loc),
.exe_sx_imm_out_reg(exe2mem_sx_imm_loc),
.exe_pc_4_out_reg(exe2mem_pc_4_loc),
.exe_w_data_out_reg(exe2mem_wdata_loc),
.exe_addr_out_reg(exe2if_addr_loc),
.exe2haz_brnch_tknn(exe2haz_brnch_tknn_loc),//be aware  

.exe_s_frm_haz_mux_trn_in(haz2exe_mux_trn)
.exe_mux_trn_out_reg(exe2if_mux_trn)
);

core_mem_s mem_s (
.clk(clk),
.rst_n(rst_n),
.mem_enb(haz2regs_enb_bus[`REG_MEM_WB]),
.mem_kill(haz2regs_kill_bus[`REG_MEM_WB]),

.mem_ld1_bus_in(exe2mem_l1d_bus_loc),
.mem_cahs_reg_in(pl_csr_addr_cach_uncash),//global //casheble or uncashble 
.mem_mux_in(exe2mem_mux_alu_mem_loc),
.mem_we_reg_file_in(exe2mem_we_reg_file_loc),
.mem_alu_result_in(exe2mem_alu_result_loc),
.mem_wrt_data_in(exe2mem_wdata_loc),
.mem_sx_imm_in(exe2mem_sx_imm_loc),
.mem_pc_4_in(exe2mem_pc_4_loc),
.mem_addr_in(exe2if_addr_loc),
.mem_wb_sx_in(exe2mem_wb_sx_cmnd),
.mem_hazrd_bus_in(exe2mem_haz_bus),

.mem_bp_mux_in(haz2mem_bp_mux),
.mem2exe_bp_data_out(mem2exe_bp_data_loc),

.mem2l1d_req_val_out_reg(pl_l1d_req_val_out),//global
.mem2l1d_req_size_out_reg(pl_l1d_req_size_out),//global
.mem2l1d_req_cop_out_reg(pl_l1d_req_cop_out),//global

.mem_wrt_data_mem_out_reg(pl_l1d_req_wdata_out),

.mem_alu_result_reg_out(mem2wb_alu_result),
.mem_sx_imm_reg_out(mem2wb_imm),
.mem_pc_4_reg_out(mem2wb_pc_4),
.mem_we_reg_file_out_reg(mem2wb_we_reg_file),
.mem_mux_out_reg(mem2wb_mux_alu_mem),
.mem_wb_sx_type_out_reg(mem2wb_sx_op),

.mem_rd_out_reg(mem2wb_rd)
);

core_wb_s wb_s(
.clk(clk),
.rst_n(rst_n),

.wb_alu_result_in(mem2wb_alu_result),
.wb_mem_data_in(pl_l1d_ack_rdata_in),//global
.wb_pc_4_in(mem2wb_pc_4),
.wb_sx_op_in(mem2wb_sx_op),
.wb_sx_imm_in(mem2wb_imm),
.wb_mux_in(mem2wb_mux_alu_mem),

.wb_ack_from_lid_in(pl_l1d_ack_ack_in),//global
.wb_we_reg_file_in(mem2wb_we_reg_file),

.wb_we_reg_file_out(wb2dec_we_reg_file),
.wb_data_out(wb2dec_data_wrt),
.wb_stall_out(wb2haz_stall),
);

hazard_ctrl	haz_ctrl(
.rst_n(rst_n),
// register controll 
.haz_enb_bus_out(haz2regs_enb_bus),
.haz_kill_bus_out(haz2regs_kill_bus),
 
.haz_pc_stop_out(haz2if_ps_stop),
.haz_nop_gen_out(haz2dec_nop_gen),
.haz_mux_trn_out(haz2exe_mux_trn),
// forwarding
.haz_bp_mux_exe_out(haz2exe_bp_mux),
.haz_bp_mux_mem_out(haz2mem_bp_mux),
// sourses and destinations
.haz_bus_exe_s_in(exe2haz_reg_bus),
.haz_bus_mem_s_in(mem2haz_reg_bus),
.haz_rd_wb_s_in(wb2haz_rd),
//we of reg file
.haz_we_reg_file_exe_s_in(exe2haz_we_reg_file),
.haz_we_reg_file_mem_s_in(mem2haz_we_reg_file),//exsessive pin 
.haz_we_reg_file_wb_s_in(wb2haz_we_reg_file),
// brnch taken from alu
.haz_brnch_tknn_in(exe2haz_brnch_tknn_loc),
// stall of cahe
.haz_stall_dec_in(dec2haz_stall),
.haz_stall_wb_in(wb2haz_stall),
// comand from each stages 
.haz_cmd_dec_s_in(dec2haz_cmd),
.haz_cmd_exe_s_in(exe2haz_cmd),
.haz_cmd_mem_s_in(mem2haz_cmd),
.haz_cmd_wb_s_in(wb2haz_cmd)
);