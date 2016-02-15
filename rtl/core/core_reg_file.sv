// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : core_reg_file.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        : register file 
// ----------------------------------------------------------------------------
module core_reg_file (
	input 				clk,
	input 				rst_n,
	input[4:0]			rs1,
	input[4:0]			rs2,
	input[4:0]			rd,
	input[31:0]			data_in,
	input 				we,
	input 				order,
	output reg [31:0]  	src1_out_r,
	output reg [31:0]  	src2_out_r
);
int i;
reg [31:0] reg_file [31:0];
always @ begin 
	if(order) begin
			src1_out_r <= reg_file[rs2];
			src2_out_r <= reg_file[rs1];
		end
		else begin
			src1_out_r <= reg_file[rs2];
			src2_out_r <= reg_file[rs1];
		end
	end
// writing to regester file 
always @(posedge clk) begin
	if(~rst_n) begin
		 for(i=0;i<32;i=i+1);
	end // if(~rst_n)
	else begin
		if(we) begin
			reg_file[rd] <= data_in;
		end // if(we)
	end	
end // always @(posedge clk)end
endmodule 