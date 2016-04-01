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

`define STRINGIFY(x) `"x`"

module core_tb_top ();

	logic clk;
	logic rst;

	string core_reg_file_path;

  initial $timeformat(-9, 1, "ns", 4);

	initial begin
		clk = 0;
		forever #10ns clk = !clk;
	end

	initial begin
		rst = 1'b1;
		repeat(5) @(posedge clk);
		rst = 1'b0;
	end

	core_if 	i_intf (clk, rst);
	core_if 	d_intf (clk, rst);

	core_commit_if commit_intf(clk, rst);

	assign commit_intf.val = dut.core.`COMMIT_VAL_PATH;

	initial begin
		core_reg_file_path = {"core_tb_top.dut.core.", `STRINGIFY(`REG_FILE_PATH)};
    `uvm_info("DBG", "Set all core registers to zero...", UVM_NONE)
		foreach(dut.core.`REG_FILE_PATH[i]) dut.core.`REG_FILE_PATH[i] = 0;
	end

	core_assembled dut
	(
		.clk 		(clk),
		.rst    (rst),
		.i_intf (i_intf),
		.d_intf (d_intf)
	);

  initial begin
    uvm_config_db#(virtual core_if)::set(uvm_root::get(), "*core_i*", "vif", i_intf);
    uvm_config_db#(virtual core_if)::set(uvm_root::get(), "*core_d*", "vif", d_intf);
    uvm_config_db#(virtual core_commit_if)::set(uvm_root::get(), "*commit_monitor*", "vif", commit_intf);
    uvm_config_db#(string)::set(uvm_root::get(), "*", "core_reg_file_path", core_reg_file_path);
  end

  initial begin
    bit [31:0] seed;
    seed = $get_initial_random_seed();
    `uvm_info("DBG", $sformatf("SEED = %0d", seed), UVM_NONE)
    #0;
    run_test();
  end

  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("core_tb_top");
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

endmodule

`endif