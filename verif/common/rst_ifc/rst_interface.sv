`ifndef INC_RST_INTERFACE
`define INC_RST_INTERFACE

interface rst_if (input wire clk);
  logic rst;
  logic soft_rst;
endinterface

`endif
