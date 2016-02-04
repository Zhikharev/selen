// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        : iwrite back phase of pipline 
// ----------------------------------------------------------------------------
module core_wb_s(

	input						clk,
	input 						rst_n,
	input						wb_enb,
	input 						wb_kill,

	input[31:0] 				wb_alu_result_in,
	input[31:0]					wb_mem_data_in,
	input[31:0]					wb_pc_4_in,
	input[2:0]					wb_sx_op_in,
	input[31:0]					wb_sx_imm_in,
	input						wb_mux_in,
	input 						wb_ack_from_lid_in,
	input 						wb_we_reg_file_in,

	output  		reg 		wb_we_reg_file_out_reg,
	output[31:0]				wb_data_out,
	output 						wb_stall_out		
);
wire[31:0] mux_out_loc;
always @(posedge clk) begin
	if(wb_enb) wb_we_reg_file_out_reg <= wb_we_reg_file_in;
	if(wb_kill) wb_we_reg_file_out_reg <= 1'b0;
end // always @(posedge clk)

assign mux_out_loc = (wb_mux_in)?wb_alu_result_in:wb_mem_data_in;

reg[31:0] data_out_loc;
always @* begin
	case(wb_sx_op_in) 
		WB_SX_BP:		data_out_loc = mux_out_loc;
		WB_SX_UB:		data_out_loc = $unsigned(mux_out_loc[7:0]);
		WB_SX_B :		data_out_loc = $signed(mux_out_loc[7:0]);
		WB_SX_H:		data_out_loc = $signed(mux_out_loc[15:0]);
		WB_SX_UH:		data_out_loc = $unsigned(mux_out_loc[15:0]);
		WB_SX_IMM:	data_out_loc = wb_sx_imm_in;	
		WB_SX_PC:		data_out_loc =  wb_pc_4_in;
	endcase // wb_sx_op_in
end
assign wb_data_out = data_out_loc;
assign wb_stall_out = (wb_ack_from_lid_in) 1'b0:1'b1;
endmodule // core_wb_s	