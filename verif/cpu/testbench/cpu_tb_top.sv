// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_tb_top.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_TB_TOP
`define INC_CPU_TB_TOP

module cpu_tb_top ();

	bit clk;

	reset_if   rst_intf (clk);
	wisbone_if wbi_intf (clk, rst_intf.rst);
	wisbone_if wbd_intf (clk, rst_intf.rst);

	cpu_assembled dut
	(
		.clk 			(clk),
		.rst      (rst_intf.rst),
		.wbi_intf (wbi_intf),
		.wbd_intf (wbd_intf)
	);

	run_test run_test(wbi_intf, wbd_intf, rst_intf);	

endmodule

`endif