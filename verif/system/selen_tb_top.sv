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

	wire gpio_pin_o;
	wire gpio_pin_en;
	wire gpio_pin_i;

	tri gpio_bus;

	assign gpio_pin_i = gpio_bus;
	assign gpio_bus = (gpio_pin_en) ? gpio_pin_o : 1'bZ;

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
			if(~rst) begin
				@(negedge clk);
				if(selen_top.cpu_cluster.core.i_req_val) begin
					string str;
					rv32_transaction item = new("item");
					str = {$sformatf("[INSTR] ADDR=%32h ", selen_top.cpu_cluster.core.i_req_addr)};
					while(!selen_top.cpu_cluster.core.i_req_ack) @(negedge clk);
					forever begin
						item.decode(selen_top.cpu_cluster.core.i_ack_rdata);
						str = {str, $sformatf("DATA=%32h ",selen_top.cpu_cluster.core.i_ack_rdata)};
						str = {str, item.sprint()};
						$display("%0s (%0t)", str, $time());
						str = {$sformatf("[INSTR] ADDR=%32h ", selen_top.cpu_cluster.core.i_req_addr)};
						do begin @(negedge clk);
						end
						while(!selen_top.cpu_cluster.core.i_req_ack);
					end
				end
			end
			else @(negedge clk);
		end
	end

	selen_top selen_top
	(
		.clk 					(clk),
		.rst_n 				(!rst),
		.gpio_pin_o 	(gpio_pin_o),
		.gpio_pin_en 	(gpio_pin_en),
		.gpio_pin_i 	(gpio_pin_i)
	);

	initial begin
		$display("%0t TEST START", $time());
		wait(selen_top.cpu_cluster.l1_cache.l1i.cache_ready);
		#1000000;
		$display("%0t TEST FINISHED", $time());
		$finish();
	end

  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("sl_tb_top");
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
  initial $readmemh("rom_image.v", selen_top.wb_rom_5kB.rom.rom);
  initial $readmemh("ram_image.v", selen_top.wb_ram_256kB.ram.ram);

endmodule

`endif
