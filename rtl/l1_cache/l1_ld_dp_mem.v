// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_ld_dp_mem.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_LD_DP_MEM
`define INC_L1_LD_DP_MEM

module l1_ld_dp_mem
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
)
(
	input 											CLK,
	input 											RST_N,
	input                       REN,
	input 	[$clog2(DEPTH)-1:0] RADDR,
	output 	[WIDTH-1:0] 				RDATA,
	input                       WEN,
	input 	[$clog2(DEPTH)-1:0] WADDR,
	input 	[WIDTH-1:0] 				WDATA,
	output                      ready
);

	localparam IDLE 	= 1'b0;
	localparam READY 	= 1'b1;

	reg 										rst_state_r;
	reg [$clog2(DEPTH)-1:0] rst_addr_r;

	wire                     wen;
	wire [$clog2(DEPTH)-1:0] waddr;
	wire [WIDTH-1:0] 				 wdata;

	always @(posedge CLK or negedge RST_N) begin
		if(~RST_N) begin
			rst_state_r <= IDLE;
		end else begin
			if(rst_state_r == IDLE) begin
				if(rst_addr_r == '1) rst_state_r <= READY;
			end
		end
	end
	always @(posedge CLK or negedge RST_N) begin
		if(~RST_N) begin
			rst_addr_r <= 0;
		end else begin
			if(rst_state_r == IDLE)
				rst_addr_r <= rst_addr_r + 1;;
		end
	end

	assign ready = ~(rst_state_r == IDLE);
	assign wen   = (rst_state_r == IDLE) ? 1'b1 : WEN;
	assign waddr = (rst_state_r == IDLE) ? rst_addr_r : WADDR;
	assign wdata = (rst_state_r == IDLE) ? '0 : WDATA;

  sram_dp
  #(
    .WIDTH (WIDTH),
    .DEPTH (DEPTH)
  )
  mem
  (
    // PORT A
    .WEA    (1'b0),
    .ENA    (REN),
    .CLKA   (CLK),
    .ADDRA  (RADDR),
    .DIA    (),
    .DOA    (RDATA),
    // PORT B
    .WEB    (1'b1),
    .ENB    (wen),
    .CLKB   (CLK),
    .ADDRB  (waddr),
    .DIB    (wdata),
    .DOB    ()
  );

endmodule
`endif