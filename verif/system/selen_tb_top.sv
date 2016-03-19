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

	initial begin
		forever begin
			@(posedge clk);
			if(selen_top.cpu_cluster.core.i_req_ack) begin
				rv32_transaction item = new("item");
				item.decode(selen_top.cpu_cluster.core.i_ack_rdata);
				$display("data=%0h",selen_top.cpu_cluster.core.i_ack_rdata);
				$display(item.sprint());
			end
		end
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

  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("tdm_tb_top");
    $fsdbDumpvars;
  end
  `elsif WAVES_VCD
  initial begin
     $dumpvars;
  end
  `elsif WAVES
  initial begin
    $vcdpluson;
  end
  `endif

  // -----------------------------------------
  // ROM IMAGE
  // -----------------------------------------
  initial $readmemh("rom_image.v", selen_top.wb_rom_1kB.rom_1kB.rom);
  initial $readmemh("rom_image.v", selen_top.wb_ram_1kB.ram_1kB.ram);

endmodule

`endif
