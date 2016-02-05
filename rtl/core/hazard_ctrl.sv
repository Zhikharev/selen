module hazard_ctrl(
	output[3:0]				haz_enb_bus_out,
	output[3:0]				haz_kill_bus_out,
	output 					haz_pc_stop_out,
	output[3:0] 			haz_bp_mux_exe_out,
	output					haz_bp_mux_mem_out,
	output					haz_nop_gen_out,

	input[14:0]				haz_bus_exe_s_in,
	input[14:0]				haz_bus_mem_s_in,
	input[4:0]				haz_rd_wb_s_in,
	input					haz_we_reg_file_exe_s_in,
	input					haz_we_reg_file_mem_s_in,//exsessive pin 
	input 					haz_we_reg_file_wb_s_in,

	input					haz_stall_dec_in,
	input 					haz_stall_wb_in

	input[1:0]				haz_cmd_dec_s_in,
	input[1:0]				haz_cmd_exe_s_in,
	input[1:0]				haz_cmd_mem_s_in,
	input[1:0]				haz_cmd_wb_s_in
);
// forwarding 
// for exe station 
wire[4:0] rs1_exe_loc;
wire[4:0] rs2_exe_loc;
wire[4:0] rd_exe_loc;
wire[4:0] rs1_mem_loc;
wire[4:0] rs2_mem_loc;
wire[4:0] rd_mem_loc;
assign rs1_exe_loc =	 haz_bus_exe_s_in[14:10];
assign rs2_exe_loc =	 haz_bus_exe_s_in[9:4];
assign rd_exe_loc =  	haz_bus_exe_s_in[4:0];
assign rs1_mem_loc =	haz_bus_mem_s_in[14:10];//exsessive pin 
assign rs2_mem_loc = 	haz_bus_mem_s_in[9:4];
assign rd_mem_loc = 	haz_bus_mem_s_in[4:0];
//exe forwarding 
assign haz_bp_mux_exe_out[1:0] = ((rs1_exe_loc == rd_mem_loc)&&(rs1_exe_loc != 5'b0)&&(haz_we_reg_file_exe_s_in))?(M2E_SRC1_BP):(
	((rs1_exe_loc == haz_rd_wb_s_in)&&(rs1_exe_loc !=5'b0)&&(haz_we_reg_file_exe_s_in))?(W2E_SRC1_BP):(BP_OFF));
assign haz_bp_mux_exe_out[3:2] =  ((rs2_exe_loc == rd_mem_loc)&&(rs2_exe_loc != 5'b0)&&(haz_we_reg_file_exe_s_in))?(M2E_SRC2_BP):(
	((rs2_exe_loc == haz_rd_wb_s_in)&&(rs2_exe_loc !=5'b0)&&(haz_we_reg_file_exe_s_in))?(W2E_SRC2_BP):(BP_OFF));
//mem forwarding
assign haz_bp_mux_mem_out = ((haz_rd_wb_s_in == rs2_mem_loc)&&(haz_we_reg_file_wb_s_in))?W2M_BP_ON :W2M_BP_OFF;

//jump 


endmodule // hazard_ctrl