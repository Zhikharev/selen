// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : selen_tb_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SELEN_TB_TOP
`define INC_SELEN_TB_TOP

`ifndef CLK_HALF_TIME
`define CLK_HALF_TIME 5ns
`endif

module selen_tb_top ();

	logic clk;
	logic rst;

	initial begin
		$display("CLK_HALF_TIME=%0d", `CLK_HALF_TIME);
		clk = 0;
		forever #`CLK_HALF_TIME clk = !clk;
	end

	initial	 begin
		rst = 1;
		repeat(5) @(posedge clk);
		rst = 0;
	end

	selen_top selen_top
	(
		.clk 		(clk),
		.rst_n 	(!rst)
	);

	initial begin
		$display("%0t TEST START", $time());
		wait(selen_top.cpu_cluster.l1_cache.l1i.cache_ready);
		#1000;
		$display("%0t TEST FINISHED", $time());
		$finish();
	end

endmodule

`endif
