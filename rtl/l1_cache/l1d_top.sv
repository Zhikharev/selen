// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1d_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------
`ifndef INC_L1D_TOP
`define INC_L1D_TOP

module l1d_top 
(
	input 													clk,
	input 													rstn,
	input 													core_req_val,
	input 	[`CORE_ADDR_WIDTH-1:0] 	core_req_addr,
	input 	[`CORE_COP_WIDTH-1:0]   core_req_cop,
	input 	[`CORE_DATA_WIDTH-1:0] 	core_req_wdata,
	input 	[`CORE_SIZE_WIDTH-1:0]  core_req_size,
	input 	[`CORE_BE_WIDTH-1:0]    core_req_be,
	output                        	core_req_ack,
	output	[`CORE_DATA_WIDTH-1:0] 	core_ack_data
);

endmodule
`endif