// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME          : core_reg_file.sv
// PROJECT            : Selen
// AUTHOR             : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 		:	AlexsandrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        : register file
// ----------------------------------------------------------------------------

module core_reg_file (
	input 					clk,
	input 					rst_n,
	input[4:0]			rs1,
	input[4:0]			rs2,
	input[4:0]			rd,
	input[31:0]			data_in,
	input 					we,
	input 					order,
	output [31:0]  	src1_out,
	output [31:0]  	src2_out
);

	int i;
	reg [31:0] reg_file [31:0];

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			for(i = 0; i< 32; i = i + 1)
				reg_file[i] <= 0;
		end else begin
			if(we) reg_file[rd] <= data_in;
		end
	end

	assign src1_out = (order) ? reg_file[rs1] : reg_file[rs2];
	assign src2_out = (order) ? reg_file[rs2] : reg_file[rs1];

endmodule
