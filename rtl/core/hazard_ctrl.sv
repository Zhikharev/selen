// ----------------------------------------------------------------------------
// FILE NAME            	: core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		: hazard controll
// ----------------------------------------------------------------------------
module hazard_ctrl(
	input 						rst_n,
	// register controll 
	output[3:0]				haz_enb_bus_out,
	output[3:0]				haz_kill_bus_out,
	// 
	output 						haz_pc_stop_out,
	output						haz_nop_gen_out,
	output						haz_mux_trn_out,
	// forwarding
	output[3:0] 			haz_bp_mux_exe_out,
	output						haz_bp_mux_mem_out,
	// sourses and destinations
	input[14:0]				haz_bus_exe_s_in,
	input[14:0]				haz_bus_mem_s_in,
	input[4:0]				haz_rd_wb_s_in,
	//we of reg file
	input							haz_we_reg_file_exe_s_in,
	input							haz_we_reg_file_mem_s_in,//exsessive pin 
	input 						haz_we_reg_file_wb_s_in,
	// brnch taken from alu
	input 						haz_brnch_tknn_in,
	// stall of cahe
	input							haz_stall_dec_in,
	input 						haz_stall_wb_in,
	// comand from each stages 
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
reg[3:0]	hazard_exe_bp_loc;
reg 			hazard_mem_bp_loc;
reg[3:0]	haz_enb_bus_loc;
reg[3:0]	haz_kill_bus_loc; 
reg 			haz_nop_gen_loc;
reg 			mux_1_loc;
assign rs1_exe_loc =	haz_bus_exe_s_in[14:10];
assign rs2_exe_loc =	haz_bus_exe_s_in[9:4];
assign rd_exe_loc =  	haz_bus_exe_s_in[4:0];
assign rs1_mem_loc =	haz_bus_mem_s_in[14:10];//exsessive pin 
assign rs2_mem_loc = 	haz_bus_mem_s_in[9:4];
assign rd_mem_loc = 	haz_bus_mem_s_in[4:0];
//forwarding of exexution stataion 
always @* begin
	hazard_exe_bp_loc = `BP_OFF;
	hazard_mem_bp_loc = `W2M_BP_OFF;
	if((rd_mem_loc == rs1_exe_loc)&&(rs1_exe_loc !=5'b0)&&(haz_we_reg_file_mem_s_in)) hazard_exe_bp_loc = `M2E_SRC1_BP;
	if((rd_mem_loc == rs2_exe_loc)&&(rs2_mem_loc !=5'b0)&&(haz_we_reg_file_wb_s_in))	hazard_exe_bp_loc = `M2E_SRC2_BP;
	if((haz_rd_wb_s_in == rs1_exe_loc)&&(rs1_exe_loc !=5'b0)&&(haz_we_reg_file_wb_s_in)) hazard_exe_bp_loc = `W2E_SRC1_BP;
	if((haz_rd_wb_s_in == rs2_exe_loc)&&(rs2_exe_loc !=5'b0)&&(haz_we_reg_file_wb_s_in)) hazard_exe_bp_loc = `W2E_SRC2_BP;
	if((haz_rd_wb_s_in == rs2_mem_loc)&&(rs2_mem_loc !=5'b0)&&(haz_we_reg_file_wb_s_in)) hazard_mem_bp_loc = `W2M_BP_ON;
end
//stall
always @* begin
	if(~rst_n)begin
		haz_kill_bus_loc = `KILL_FULL_ON;
		mux_1_loc = 1'b0;
		haz_nop_gen_loc = `NOP_GEN_OFF;
	end
	else begin
		haz_enb_bus_loc = `ENB_FULL_ON;
		haz_kill_bus_loc = `KILL_FULL_OFF;
		haz_nop_gen_loc = `NOP_GEN_OFF;
		mux_1_loc = 1'b0;	
		// jump
		if(haz_cmd_dec_s_in == `HZRD_JMP)begin
			haz_kill_bus_loc[`REG_IF_DEC] = `REG_KILL_ON;
			haz_enb_bus_loc[`REG_IF_DEC] = `REG_ENB_OFF;
		end
		if(haz_cmd_exe_s_in == `HZRD_JMP)begin
			haz_nop_gen_loc = `NOP_GEN_ON;
			mux_1_loc = 1'b1;
		end
		if(haz_cmd_mem_s_in == `HZRD_JMP)begin
			//mux_1_loc = 1'b1;
			haz_enb_bus_loc[`REG_IF_DEC] = `REG_ENB_ON;
			haz_nop_gen_loc = `NOP_GEN_ON;			
		end
		// jump stall end
		//brnch begin
		if(haz_cmd_exe_s_in == `HZRD_BRNCH)begin
			if(haz_brnch_tknn_in == 1'b1) begin
				mux_1_loc = 1'b1;
				haz_kill_bus_loc = `KILL_BRNCH;
			end
			else begin
				mux_1_loc =1'b0;
				haz_kill_bus_loc = `KILL_FULL_OFF;
			end
		end
		//brnch end
		// load begin
		if(haz_cmd_exe_s_in == `HZRD_LOAD)begin
			haz_nop_gen_loc = `NOP_GEN_ON;
			haz_enb_bus_loc[`REG_IF_DEC] = `REG_ENB_OFF;
		end
		//load end
		if(haz_stall_wb_in) begin
			haz_enb_bus_loc = `ENB_FULL_OFF;
		end
		if(haz_stall_dec_in)begin
			
		end
			haz_enb_bus_loc[`REG_IF_DEC] = `REG_ENB_OFF;
			haz_nop_gen_loc = `NOP_GEN_ON; 
		end
	end
end
assign haz_pc_stop_out = (haz_enb_bus_loc == `ENB_FULL_ON)?1'b0:1'b1;


assign haz_bp_mux_exe_out = hazard_exe_bp_loc;
assign haz_bp_mux_mem_out	=	hazard_mem_bp_loc;
assign haz_enb_bus_out	haz_enb_bus_loc;
assign haz_kill_bus_out = haz_kill_bus_loc; 
assign haz_nop_gen_out = haz_nop_gen_loc;
assign haz_mux_trn_out = mux_1_loc;
endmodule // hazard_ctrl