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
	input 								clk,
	input 								if_pc_stop,
	input 								rst_n,
	input									if_enb,
	input									if_kill,
	input									if_mux1_trn_pc_4_s,
	input[31:0]						if_mux1_addr,
	output 								if_val,
	output[31:0]	reg			if_pc,
	output[31:0]	reg			if_pc_4, 				
);
wire[31:0] npc;
always@(posedge clk)begin 
	if(~rst_n)begin 
		if_pc <= 31'0;
	end
	else begin
		if(if_pc_stop)	if_pc <= if_pc;
		else if_pc <= npc;
	end	
end
assign if_pc_4 = if_pc + 4;
assign npc = (if_mux1_trn_pc_4_s)? if_mux1_add : npc;
endmodule