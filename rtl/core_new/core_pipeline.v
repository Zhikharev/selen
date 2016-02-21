// ----------------------------------------------------------------------------
// FILE NAME            	: core_pipeline.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexsandrBolotnikov@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION        		: connection bwtwine all modules of stage and
//                          hazard controll
// ----------------------------------------------------------------------------
`ifndef INC_CORE_PIPEPILNE
`define INC_CORE_PIPEPILNE

module core_pipeline
	(
		input 					clk,
		input  					rst_n,

		input 	[31:0] 	csr_nc_base,
		input 	[31:0]  csr_nc_mask,

		// l1i
		input[	31:0]		pl_l1i_ack_rdata,
		input 					pl_l1i_ack,
		output 					pl_l1i_req_val,
		output	[31:0]	pl_l1i_req_aadr,

	//l1d
		output					pl_l1d_req_val,
		output 	[31:0] 	pl_l1d_req_addr,
		output 	[2:0] 	pl_l1d_req_cop,
		output  [31:0] 	pl_l1d_req_wdata,
		output 	[2:0]		pl_l1d_req_size,
		input 					pl_l1d_ack_ack,
		input 	[31:0]	pl_l1d_ack_rdata
	);



endmodule
`endif