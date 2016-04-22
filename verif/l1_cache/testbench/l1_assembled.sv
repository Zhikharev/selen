`ifndef INC_L1_ASSEMBLED
`define INC_L1_ASSEMBLED

module l1_assembled
(
	input 	clk,
	input 	rst_n,
  core_if l1i_intf,
  core_if l1d_intf,
	wb_if 	wb_intf
);

l1_top l1
(
	.clk                    (clk),
  .rst_n                  (rst_n),

  // L1I interface
  .l1i_req_val            (l1i_intf.req_val),
  .l1i_req_addr           (l1i_intf.req_addr),
  .l1i_req_ack            (l1i_intf.req_ack),
  .l1i_ack_data           (l1i_intf.req_ack_data),

  // L1D interface
  .l1d_req_val            (l1d_intf.req_val),
  .l1d_req_cop            (l1d_intf.req_cop),
  .l1d_req_size           (l1d_intf.req_size),
  .l1d_req_addr           (l1d_intf.req_addr),
  .l1d_req_wdata          (l1d_intf.req_wdata),
  .l1d_req_ack            (l1d_intf.req_ack),
  .l1d_ack_data           (l1d_intf.req_ack_data),

  // Wishbone B4 interface
  .wb_clk_i               (wb_intf.clk),
  .wb_rst_i               (wb_intf.rst),
  .wb_dat_i               (wb_intf.dat_i),
  .wb_dat_o               (wb_intf.dat_o),
  .wb_ack_i               (wb_intf.ack),
  .wb_adr_o               (wb_intf.adr),
  .wb_cyc_o               (wb_intf.cyc),
  .wb_stall_i             (wb_intf.stall),
  .wb_err_i               (wb_intf.err),    // not used now
  .wb_lock_o              (wb_intf.lock),   // not used now
  .wb_rty_i               (wb_intf.rty),    // not used now
  .wb_sel_o               (wb_intf.sel),
  .wb_stb_o               (wb_intf.stb),
  .wb_tga_o               (wb_intf.tga),    // not used now
  .wb_tgc_o               (wb_intf.tgc),    // not used now
  .wb_we_o                (wb_intf.we)
);

endmodule

`endif