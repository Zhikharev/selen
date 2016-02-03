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
`include "core_defines.vh"
module core_if_s (
	input 							clk,// system clock 
	input 							if_pc_stop,// stop counting for pc 
	input 							rst_n,// system reset 
	input							if_enb,// enable for fetch/decode register 
	input							if_kill,//clear fetch/decode register 
	input							if_mux1_trn_pc_4_s,// select signsl for mux chousing next pc source
	input[31:0]						if_mux1_addr,// adrress for branch or jump 
	output 							if_val,// actuality of request to livel 1 instruction cash
	output[31:0]	reg				if_pc,// pc output from fetch/ decode register 
	output[31:0]	reg				if_pc_4//pc_4 output from fetch/ decode register  				
);
wire[31:0] npc;
always@(posedge clk)begin 
	if(~rst_n)begin 
		if_pc <= PS_START;
	end
	else begin
		if(if_pc_stop)	if_pc <= if_pc;
		else if_pc <= npc;
	end	
	if(if_kill) begin
		if_pc <= 32'b0;
		if_pc_4 <= 32'b0;
	end
	if(~if_enb) begin
		if_pc <= if_pc;
		if_pc_4 <= if_pc_4;
	end
end
assign if_val = (rst_n) ? 1'b1:1'b0;
assign if_pc_4 = if_pc + 4;
assign npc = (if_mux1_trn_pc_4_s)? if_mux1_add : npc;
endmodule