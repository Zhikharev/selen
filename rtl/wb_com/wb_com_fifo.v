module          wb_com_fifo
(
clk,
rst,

wr_en,
wr_data,

rd_en,
rd_data,

full,
empty
);
parameter   DATA_W  = 32;
parameter   SIZE    = 4;

input                   clk;
input                   rst;

input                   wr_en;
input   [DATA_W-1:0]    wr_data;

input                   rd_en;
output  [DATA_W-1:0]    rd_data;

output                  full;
output                  empty;

reg 	[DATA_W-1 :0]   mem [(1<<SIZE)-1:0];
reg     [SIZE:0]        wr_ptr, rd_ptr;

always @(posedge clk)
if (rst)            wr_ptr <= {SIZE+1{1'b0}};
else if (wr_en)     wr_ptr <= wr_ptr + 1'b1;

always @(posedge clk)
if (rst)            rd_ptr <= {SIZE+1{1'b0}};
else if (rd_en)     rd_ptr <= rd_ptr + 1'b1;

always @(posedge clk)
if (wr_en) mem[wr_ptr[SIZE-1:0]] <= wr_data;

assign rd_data = mem[rd_ptr[SIZE-1:0]];

assign full = (rd_ptr[SIZE] != wr_ptr[SIZE]) & (rd_ptr[SIZE-1:0] == wr_ptr[SIZE-1:0]);
assign empty = (wr_ptr == rd_ptr);

endmodule
