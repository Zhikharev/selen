// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            		:core_if_s.sv
// PROJECT                		:Selen
// AUTHOR               		:Alexsandr Bolotnokov
// AUTHOR'S EMAIL 	    		:AlexsandrBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		:instruction fetch phase of pipline 
// ----------------------------------------------------------------------------
module core_if_s (
	input 						clk,// system clock 
	input 						rst_n,// system reset 
	//register ctrl
	input						if_enb,// enable for fetch/decode register 
	input						if_kill,//clear fetch/decode register 
	//from haz	
	input						if_mux1_trn_pc_4_s,// select signsl for mux chousing next pc source
	input 						if_pc_stop,// stop counting for pc 
	//
	input[31:0]					if_mux1_addr,// adrress for branch or jump 
	output 						if_val,// actuality of request to livel 1 instruction cash
	output reg [31:0]			if_lid_pc_out_reg,// pc output from fetch/ decode register 
	// to decode
	output reg [31:0]	 		if_pc,
	output reg [31:0]			if_pc_4//pc_4 output from fetch/ decode register  				
);
wire[31:0]  pc_4_adder;
wire [31:0] pc_next;
reg[31:0] 	pc_loc;
reg[31:0]	pc4_loc;
always @(posedge clk) begin 
	if(~rst_n) begin
		pc_loc <= `PC_START;
	end // if(~rst_n)end	
	else begin
		if(if_pc_stop) begin
			pc_loc <= pc_loc;		
		end
		else begin
			pc_loc <= pc_next;	
		end // else
	end // else
end

always @(posedge clk)begin
	if(if_enb) begin
		if_pc<= pc_loc;
		if_pc_4  <=  pc_4_adder;
		if(if_kill) begin
			if_pc <= 31'b0;
			if_pc_4 <= 31'b0;
		end // if(if_kill)
	end
	if(if_kill) begin
		if_pc <= 31'b0;
		if_pc_4 <= 31'b0;
	end // if(if_kill)
end
assign pc_4_adder = pc_loc + 4;
assign pc_next = (if_mux1_trn_pc_4_s)? if_mux1_addr:pc_4_adder;
assign if_val =1'b1;
endmodule // core_if_s