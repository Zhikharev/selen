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

	logic clk;

	initial begin
		clk = 0;
		forever #10 clk = !clk;
	end

	reset_if   rst_intf (clk);
	wishbone_if wbi_intf (clk, rst_intf.rst);
	wishbone_if wbd_intf (clk, rst_intf.rst);

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