// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_tb_top.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_L1_TB_TOP
`define INC_L1_TB_TOP

module l1_tb_top;

	reg sys_clk;
	wire reset;

  initial begin
    sys_clk = 1'b0;
    `uvm_info("DBG", $sformatf("sys_clk half period = %0d", `CLK_HALF_PERIOD), UVM_NONE)
    forever #(`CLK_HALF_PERIOD) sys_clk = ~sys_clk;
  end

  // Reset interface
  rst_if rst_intf(sys_clk);
  assign reset = rst_intf.rst | rst_intf.soft_rst;

  wb_if  wb_intf(sys_clk, reset);
  assign wb_intf.clk_i = sys_clk;
  assign wb_intf.rst_i = reset;

  core_if l1i_intf(sys_clk, reset);
  core_if l1d_intf(sys_clk, reset);

  l1_assembled dut
  (
  	.clk 			    (sys_clk),
  	.rst_n   	    (!reset),
    .l1i_intf     (l1i_intf),
    .l1d_intf     (l1d_intf),
  	.wb_intf      (wb_intf)
  );

  typedef virtual core_if   v_core;
  typedef virtual wb_if   	v_wb;

  initial begin
    uvm_config_db#(virtual rst_if)::set(null,  "*rst_agent*", "vif", rst_intf)	;
    uvm_config_db#(v_core)::set(uvm_root::get(),"*l1i_agent*", "vif", l1i_intf);
    uvm_config_db#(v_core)::set(uvm_root::get(),"*lid_agent*", "vif", l1d_intf);
    uvm_config_db#(v_wb)::set(uvm_root::get(),		"*wb_agent*", "vif", wb_intf)	;
  end

  bit [31:0] seed;

    initial begin
      seed = $get_initial_random_seed();
      `uvm_info("DBG", $sformatf("SEED = %0d", seed), UVM_NONE)
      #0;
      run_test();
    end

  initial $timeformat(-9, 1, "ns", 4);
endmodule

`endif