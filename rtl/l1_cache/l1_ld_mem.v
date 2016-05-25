// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_ld_mem.v
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_LD_MEM
`define INC_L1_LD_MEM

module l1_ld_mem
#(
	parameter WIDTH = 32,
	parameter DEPTH = 1024
)
(
	input 											CLK,
	input 											RST_N,
	input                       EN,
	input 	[$clog2(DEPTH)-1:0] ADDR,
	input                       WE,
	input 	[WIDTH-1:0] 				WDATA,
	output 	[WIDTH-1:0] 				RDATA,
	output                      ready
);

	localparam IDLE 	= 1'b0;
	localparam READY 	= 1'b1;

	reg 										rst_state_r;
	reg [$clog2(DEPTH)-1:0] rst_addr_r;

	wire 										 en;
	wire [$clog2(DEPTH)-1:0] addr;
	wire                     we;
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
				rst_addr_r <= rst_addr_r + 1;
		end
	end

	assign ready = ~(rst_state_r == IDLE);

	assign en    = (rst_state_r == IDLE) ? 1'b1 : EN;
	assign we    = (rst_state_r == IDLE) ? 1'b1 : WE;
	assign addr  = (rst_state_r == IDLE) ? rst_addr_r : ADDR;
	assign wdata = (rst_state_r == IDLE) ? {WIDTH{1'b0}} : WDATA;

`ifdef PROTO
	// Xilinx ISE sram IP-core
	sram_sp_20x256
`else
	sram_sp
	#(
		.WIDTH  (WIDTH),
		.DEPTH 	(DEPTH)
	)
`endif
	mem
	(
		.clka 	(CLK),
		.ena 		(en),
		.wea 		(we),
		.addra 	(addr),
		.dina 	(wdata),
		.douta 	(RDATA)
	);

endmodule
`endif