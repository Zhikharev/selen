// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : core_if_s.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        : instruction fetch phase of pipline 
// ----------------------------------------------------------------------------
module core_if_s (
	input 							clk,// system clock 
	input 							rst_n,// system reset 
	//register ctrl
	input								if_enb,// enable for fetch/decode register 
	input								if_kill,//clear fetch/decode register 
	//from haz	
	input								if_mux1_trn_pc_4_s,// select signsl for mux chousing next pc source
	input 							if_pc_stop,// stop counting for pc 
	//
	input[31:0]					if_mux1_addr,// adrress for branch or jump 
	output 							if_val,// actuality of request to livel 1 instruction cash
	output[31:0]	reg		if_lid_pc_out_reg,// pc output from fetch/ decode register 
	// to decode
	output[31:0]	reg 	if_pc,
	output[31:0]	reg		if_pc_4,//pc_4 output from fetch/ decode register  				
);
wire[31:0] npc;
reg[31:0]	if_pc_loc;
always@(posedge clk)begin 
	if(~rst_n)begin 
		if_pc_loc <= `PS_START;
	end
	else begin
		if(if_pc_stop)	if_pc_loc <= if_pc_loc;
		else if_pc_loc <= npc;
	end	
	if(if_kill) begin
		if_pc <= 32'b0;
		if_pc_4 <= 32'b0;
	end
	if(~if_enb) begin
		if_pc <= if_pc_loc;
		if_pc_4 <= if_pc_4;
	end
end
assign if_lid_pc_out_reg = if_pc_loc;
assign if_val = 1'b1;
assign if_pc_4 = if_pc_loc + 4;
assign npc = (if_mux1_trn_pc_4_s)? if_mux1_add : if_pc_4;
endmodule