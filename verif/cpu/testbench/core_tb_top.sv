// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : core_tb_top.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CORE_TB_TOP
`define INC_CORE_TB_TOP

module core_tb_top ();

	logic clk;

  initial $timeformat(-9, 1, "ns", 4);

	initial begin
		clk = 0;
		forever #10ns clk = !clk;
	end

	initial begin
		rst_intf.rst = 1'b1;
		repeat(5) @(posedge clk);
		rst_intf.rst = 1'b0;
	end

	reset_if  rst_intf (clk);
	core_if 	i_intf (clk, rst_intf.rst);
	core_if 	d_intf (clk, rst_intf.rst);

	core_assembled dut
	(
		.clk 		(clk),
		.rst    (rst_intf.rst),
		.i_intf (i_intf),
		.d_intf (d_intf)
	);

	run_test run_test(i_intf, d_intf, rst_intf);	

endmodule

`endif