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
`define CLK_HALF_TIME 16ns
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

  wire   spi_ss;
  wire   spi_sclk;
  wire   spi_mosi;
  wire   spi_miso;

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

	// ----------------------------------
	// TRACERS
	// ----------------------------------
	 wb_if spi_wb_intf(
	 	.clk (selen_top.perif_cluster.spi.wb_clk_i),
	 	.rst (selen_top.perif_cluster.spi.wb_rst_i)
	 );

	 assign spi_wb_intf.adr 	= selen_top.perif_cluster.spi.wb_adr_i;
	 assign spi_wb_intf.dat_i = selen_top.perif_cluster.spi.wb_dat_i;
	 assign spi_wb_intf.dat_o = selen_top.perif_cluster.spi.wb_dat_o;
	 assign spi_wb_intf.sel 	= selen_top.perif_cluster.spi.wb_sel_i;
	 assign spi_wb_intf.we 		= selen_top.perif_cluster.spi.wb_we_i;
	 assign spi_wb_intf.stb 	= selen_top.perif_cluster.spi.wb_stb_i;
	 assign spi_wb_intf.cyc 	= selen_top.perif_cluster.spi.wb_cyc_i;
	 assign spi_wb_intf.ack 	= selen_top.perif_cluster.spi.wb_ack_o;
	 assign spi_wb_intf.err 	= selen_top.perif_cluster.spi.wb_err_o;

	sl_wb_tracer spi_wb_tr(spi_wb_intf);

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
						//$display("%0s (%0t)", str, $time());
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
		.gpio_pin0_o 	(),
		.gpio_pin0_en (),
		.gpio_pin0_i 	(1'b1),
		.gpio_pin1_o 	(gpio_pin_o),
		.gpio_pin1_en (gpio_pin_en),
		.gpio_pin1_i 	(gpio_pin_i),
  	.spi_ss_o 		(spi_ss),
  	.spi_sclk_o 	(spi_sclk),
  	.spi_mosi_o 	(spi_mosi),
  	.spi_miso_i 	(spi_miso)
	);

 	N25Qxxx spi_flash
 	(
 		.S  				(spi_ss),
 		.C_  				(spi_sclk),
 		.HOLD_DQ3 	(1'b1),
 		.DQ0 				(spi_mosi),
 		.DQ1 				(spi_miso),
 		.Vcc 				('d3000),
 		.Vpp_W_DQ2 	(1'b1)
 	);

	initial begin
		$display("%0t TEST START", $time());
		wait(selen_top.cpu_cluster.core.d_req_val && selen_top.cpu_cluster.core.d_req_addr == 32'hffff_fff0);
		$display("%0t TEST FINISHED", $time());
		$finish();
	end

  initial $timeformat(-9, 1, "ns", 4);

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
