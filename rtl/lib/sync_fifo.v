// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sync_fifo.v
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SYNC_FIFO
`define INC_SYNC_FIFO

module sync_fifo
#(
  parameter DWIDTH = 8,
  parameter AWIDTH = 8
)
(
  input                        clk,
  input                        rst,
  input                        fifo_we,
  input                        fifo_re,
  input         [DWIDTH -1 :0] fifo_wd,
  output reg    [DWIDTH -1 :0] fifo_rd,
  output wire                  fifo_full,
  output wire                  fifo_empty
);


  wire [AWIDTH-1:0] fifo_wa, fifo_ra;
  reg [DWIDTH-1:0] fifo_array [0:(1<<AWIDTH)-1];
  reg [AWIDTH:0] fifo_wptr, fifo_rptr;
  wire                            fifo_full_w;
  wire                            fifo_empty_w;

  assign fifo_full = fifo_full_w;
  assign fifo_empty = fifo_empty_w;

  always @(posedge clk, posedge rst)
    if(rst) fifo_wptr <= {AWIDTH+1{1'b0}};
    else if (fifo_we & !fifo_full_w) fifo_wptr <= fifo_wptr + {{AWIDTH{1'b0}},1'b1};

  always @(posedge clk, posedge rst)
    if(rst) fifo_rptr <= {AWIDTH+1{1'b0}};
    else if (fifo_re & !fifo_empty_w) fifo_rptr <= fifo_rptr + {{AWIDTH{1'b0}},1'b1};

  assign fifo_wa = fifo_wptr[AWIDTH-1:0];
  assign fifo_ra = fifo_re? (fifo_rptr[AWIDTH-1:0] + {{AWIDTH-1{1'b0}},1'b1}) : fifo_rptr[AWIDTH-1:0];

  always @(posedge clk)
    if(fifo_we & !fifo_full_w) fifo_array[fifo_wa] <= fifo_wd;

  always @(posedge clk, posedge rst)
    if(rst) fifo_rd <= {DWIDTH{1'b0}};
    else if (fifo_we & (fifo_wa == fifo_ra) & !fifo_full_w) fifo_rd <= fifo_wd;
    else fifo_rd <= fifo_array[fifo_ra];

  assign fifo_full_w = (fifo_wptr[AWIDTH]^fifo_rptr[AWIDTH]) & (fifo_wptr[AWIDTH-1:0] == fifo_rptr[AWIDTH-1:0]);
  assign fifo_empty_w = (fifo_wptr[AWIDTH:0] == fifo_rptr[AWIDTH:0]);

endmodule

`endif