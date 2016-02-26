// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : core_assembled.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_CORE_ASSEMBLED
`define INC_CORE_ASSEMBLED


module core_assembled (
	input 				clk,
	input 				rst,
	core_if 			i_intf,
	core_if 			d_intf
);

	core_top core
	(
		.clk 					(clk),
		.rst_n  			(!rst),
		.i_req_val 		(i_intf.req_val),
		.i_req_addr 	(i_intf.req_addr),
		.i_req_ack 		(i_intf.req_ack),
		.i_ack_rdata	(i_intf.req_ack_data),
		.d_req_val 		(d_intf.req_val),
		.d_req_addr 	(d_intf.req_addr),
		.d_req_cop 		(d_intf.req_cop),
		.d_req_wdata 	(d_intf.req_wdata),
		.d_req_size 	(d_intf.req_size),
		.d_req_ack 		(d_intf.req_ack),
		.d_ack_rdata 	(d_intf.req_ack_data)
	);
/*
	assign i_intf.req_val = 1'b1;
	assign d_intf.req_val = 1'b0;
*/
	assign i_intf.req_cop  = 3'b000;
	assign i_intf.req_size = 4;

endmodule

`endif
