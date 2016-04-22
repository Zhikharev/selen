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
				if(rst_addr_r == {`CORE_IDX_WIDTH{1'b1}}) rst_state_r <= READY;
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
	assign wdata = (rst_state_r == IDLE) ? {WIDTH{1'b0}} : WDATA;

`ifdef PROTO
	// Xilinx ISE sram IP-core
	sram_dp_20x256
`else
  sram_dp
  #(
    .WIDTH (WIDTH),
    .DEPTH (DEPTH)
  )
`endif
  mem
  (
  	// PORT A
		.clka 	(CLK),
		.ena 		(wen),
		.wea 		(1'b1),
		.addra 	(waddr),
		.dina 	(wdata),
		.douta 	(),
		// PORT B
		.clkb 	(CLK),
		.enb 		(REN),
		.web 		(1'b0),
		.addrb 	(RADDR),
		.dinb 	(),
		.doutb 	(RDATA)
  );

endmodule
`endif