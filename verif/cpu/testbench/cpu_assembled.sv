// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_assembled.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_ASSEMBLED
`define INC_CPU_ASSEMBLED

`include "alu.v"
`include "brnch_cnd.v"
`include "cpu_cntr.v"
`include "hazard_unit.v"
`include "reg_decode.v"
`include "reg_exe.v"
`include "reg_mem.v"
`include "reg_write.v"
`include "register_file.v"
`include "mem_block.v"
`include "sx_2.v"
`include "cpu_top.v"
module cpu_assembled (
	input 				clk,
	input 				rst,
	wishbone_if 	wbi_intf,
	wishbone_if 	wbd_intf
);

	assign wbi_intf.we = 1'b0;

	// Instantiate CPU DUT here
	system top 
	(
		.inst_cyc_out 	(wbi_intf.cyc),
		.inst_stb_out 	(wbi_intf.stb),
		.inst_addr_out 	(wbi_intf.addr),
		.inst_ack_in 		(wbi_intf.ack),
		.inst_data_in 	(wbi_intf.data_in),
		.inst_stall_in 	(wbi_intf.stall),
		.data_stb_out 	(wbd_intf.stb),
		.data_we_out 		(wbd_intf.we),
		.data_be_out 		(wbd_intf.be),
		.data_ack_in 		(wbd_intf.ack),
		.data_addr_out 	(wbd_intf.addr),
		.data_data_out 	(wbd_intf.data_out),
		.data_data_in 	(wbd_intf.data_in),
		.data_stall_in  (wbd_intf.stall),
		.sys_clk 				(clk),
		.sys_rst 				(rst)
);

endmodule

`endif
