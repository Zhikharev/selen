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
	input[4:0]			rs1_in,
	input[4:0]			rs2_in,
	input[4:0]			rd_in,
	input[31:0]			data_in,
	input 					we_in,
	input 					order_in,
	output [31:0]  	src1_out,
	output [31:0]  	src2_out
);

	integer i;
	reg [31:0] reg_file [31:0];

	always@(posedge clk or negedge rst_n) begin
		reg_file[0] <= 0;
		if(~rst_n) begin
			for(i = 0; i< 32; i = i + 1)
				reg_file[i] <= 0;
		end else begin
			if(we_in) reg_file[rd_in] <= data_in;
		end
	end
	assign src1_out = (order_in) ? reg_file[rs1_in] : reg_file[rs2_in];
	assign src2_out = (order_in) ? reg_file[rs2_in] : reg_file[rs1_in];

endmodule
