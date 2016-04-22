
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME       : wb_ram.v
// PROJECT         : Selen
// AUTHOR          :
// AUTHOR'S EMAIL  :
// ----------------------------------------------------------------------------
// DESCRIPTION     :
// ----------------------------------------------------------------------------
`ifndef INC_WB_RAM
`define INC_WB_RAM

module wb_ram (
  wb_clk_i,
  wb_rst_i,
  wb_dat_i,
  wb_dat_o,
  wb_adr_i,
  wb_sel_i,
  wb_we_i,
  wb_cyc_i,
  wb_stb_i,
  wb_ack_o,
  wb_err_o
);

parameter
    AW = 32,
    DW = 32;

input                   wb_clk_i;
input                   wb_rst_i;

input   [DW-1:0]        wb_dat_i;
output  [DW-1:0]        wb_dat_o;
input   [AW-1:0]        wb_adr_i;
input   [DW/8-1:0]      wb_sel_i;
input                   wb_we_i ;
input                   wb_cyc_i;
input                   wb_stb_i;
output                  wb_ack_o;
output                  wb_err_o;

reg                     wb_ack_r;
reg                     wb_err_r;

wire                    mem_clk_i;
wire                    mem_en_i ;
wire                    mem_we_i;
wire    [DW/8-1:0]      mem_wbe_i;
wire    [AW:0]          mem_adr_i;
wire    [DW-1:0]        mem_dat_o;
wire    [DW-1:0]        mem_dat_i;

// ----------------------------------------------------------------------------
// Inst of RAM
sram_sp_be
#(
  .WIDTH (DW),
  .DEPTH (1<<AW)
)
ram
(
  .WE   (mem_we_i),
  .WBE  (mem_wbe_i),
  .EN   (mem_en_i),
  .CLK  (mem_clk_i),
  .ADDR (mem_adr_i),
  .DI   (mem_dat_i),
  .DO   (mem_dat_o)
);

assign mem_en_i  = wb_stb_i;
assign mem_we_i  = wb_we_i;
assign mem_wbe_i = wb_sel_i;
assign mem_clk_i = wb_clk_i;
assign mem_adr_i = wb_adr_i[AW-1:2];
assign mem_dat_i = wb_dat_i;

assign wb_dat_o  = mem_dat_o;
// ----------------------------------------------------------------------------

always @(posedge wb_clk_i or posedge wb_rst_i) begin
  if (wb_rst_i)
      wb_ack_r <= 1'b0;
  else
    wb_ack_r <= wb_cyc_i & wb_stb_i;
end

assign wb_ack_o = wb_ack_r;
assign wb_err_o = 1'b0;

endmodule

`endif