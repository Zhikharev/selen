module cpu_dec_s(
	input[31:0]					dec_inst,
	input[31:0]					dec_data_wrt,
	input								dec_clk,
	input								dec_kill,
	input								dec_il1_ack,
	input								dec_we_reg_file_in,
	output				reg 	dec_we_reg_file_out		
	output							dec_stall,
	output[31:0]	reg		dec_src1,
	output[31:0]	reg		dec_src2,
	output[31:0]	reg		dec_pc,
	output[31:0]	reg		dec_pc_4,
	output[31:0]	reg		dec_sx_imm,
	output[4:0]		reg		dec_ld1,
	output[5:0]		reg		dec_mux_bus,
	output[2:0]		reg		dec_brnch_cnd,
	output[3:0]		reg		dec_alu_op,	
	output[14:0]	reg		dec_hazard_bus
);