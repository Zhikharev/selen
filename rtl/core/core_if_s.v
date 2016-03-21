// ----------------------------------------------------------------------------
// FILE NAME            	: core_csr.sv
// PROJECT                : Selen
// AUTHOR                 :	Alexandr Bolotnikov	
// AUTHOR'S EMAIL 				:	AlexsanrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		:	A description of instruction fetch station
// ----------------------------------------------------------------------------
//include core_defines.vh;

module core_if_s (
	input							clk,
	input							rst_n,
	//register control
	input 						if_kill,
	input 						if_enb,
	//from hazard control
	input 						if_mux_trn_s_in,
	// for transfer of address
	input[31:0]				if_addr_mux_trn_in,
	//for l1i $
	output[31:0]			if_addr_l1i_cash_out,
	output						if_val_l1i_cahe_out,
	//register if/dec
	output	reg[31:0]	if_pc_reg_out,	
	output 	reg[31:0]	if_pc_4_reg_out,
	output 	reg 			if_start_out_reg
);
reg[31:0] 	pc_reg;
wire[31:0] 	pc_adder;
wire[31:0] 	pc_next;
//program counter
always @(posedge clk , negedge rst_n)begin//, negedge rst_n)begin
	if(~rst_n) begin
		pc_reg <= `PC_START;
	end
	else begin
		if(if_enb) begin
			 pc_reg <= pc_next;
		end
		else begin
			pc_reg <= pc_reg;	
		end
	end
end
//adder and mux
assign pc_next= (if_mux_trn_s_in)?(if_addr_mux_trn_in):(pc_adder);
assign pc_adder = pc_reg + 4;
assign if_addr_l1i_cash_out = pc_reg;
assign if_val_l1i_cahe_out = 1'b1;
//register if/decode
always @(posedge clk , negedge rst_n) begin
	if(~rst_n) if_start_out_reg <= 1'b0;
	else if_start_out_reg <= 1'b1;
end
always @(posedge clk) begin
	if(if_kill) begin
		if_pc_reg_out <= 0;
		if_pc_4_reg_out <= 0;
	end
	if(if_enb)begin
		if_pc_4_reg_out <= pc_adder;
		if_pc_reg_out <= pc_reg;
	end
end
endmodule

