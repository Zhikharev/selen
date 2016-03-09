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
//assign l1i_intf. = 
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
  .l1d_req_be             ( 4'hF ),

  // Wishbone B4 interface
  .wb_clk_i               (wb_intf.clk_i),
  .wb_rst_i               (wb_intf.rst_i),
  .wb_dat_i               (wb_intf.dat_i),
  .wb_dat_o               (wb_intf.dat_o),
  .wb_ack_i               (wb_intf.ack_i),
  .wb_adr_o               (wb_intf.adr_o),
  .wb_cyc_o               (wb_intf.cyc_o),
  .wb_stall_i             (wb_intf.stall_i),
  .wb_err_i               (wb_intf.err_i),    // not used now
  .wb_lock_o              (wb_intf.lock_o),   // not used now
  .wb_rty_i               (wb_intf.rty_i),    // not used now
  .wb_sel_o               (wb_intf.sel_o),
  .wb_stb_o               (wb_intf.stb_o),
  .wb_tga_o               (wb_intf.tga_o),    // not used now
  .wb_tgc_o               (wb_intf.tgc_o),    // not used now
  .wb_we_o                (wb_intf.we_o)
);

endmodule

`endif