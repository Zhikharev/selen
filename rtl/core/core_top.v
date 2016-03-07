// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME            	: core_top.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		: top module for pipeline CPU include interconection
//                          betwin pipline module and CRS module
// ----------------------------------------------------------------------------
module core_top
	(
		input 					clk,
		input 					rst_n,

		//instruction inteface
		output 					i_req_val,
		output[31:0] 		i_req_addr,
		input 					i_req_ack,
		input[31:0] 		i_ack_rdata,

		//data interface
		output 					d_req_val,
		output[31:0] 		d_req_addr,
		output[2:0]			d_req_cop,
		output[31:0] 		d_req_wdata,
		output[2:0] 		d_req_size,
		input						d_req_ack,
		input[31:0]			d_ack_rdata
	);

wire [31:0] csr_nc_base;
wire [31:0] csr_nc_mask;

core_pipeline pipeline
(
	.clk 								(clk),
	.rst_n 							(rst_n),
	.csr_nc_base 				(csr_nc_base),
	.csr_nc_mask 				(csr_nc_mask),
	//l1i
	.pl_l1i_ack_rdata 	(i_ack_rdata),
	.pl_l1i_ack 				(i_req_ack),
	.pl_l1i_req_val 		(i_req_val),
	.pl_l1i_req_addr 		(i_req_addr),
	//l1d
	.pl_l1d_req_val 		(d_req_val),
	.pl_l1d_req_addr 		(d_req_addr),
	.pl_l1d_req_cop 		(d_req_cop),
	.pl_l1d_req_wdata 	(d_req_wdata),
	.pl_l1d_req_size 		(d_req_size),
	.pl_l1d_ack_ack 		(d_req_ack),
	.pl_l1d_ack_rdata 	(d_ack_rdata)
);

core_csr csr
(
	.clk 			 			(clk),
	.rst_n 					(rst_n),
	.ncache_base    (csr_nc_base),
	.ncache_mask 		(csr_nc_mask)
);

/*
Хит в некэшириуемую область должен определяться следующим образом
assign nc_hit = (addr & ~({ADDR_WIDTH{1'b0}} | ADDR_MASK)) == ADDR_BASE;
*/

endmodule