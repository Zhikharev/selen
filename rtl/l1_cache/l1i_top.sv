// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1i_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : core_req_cop = RD core_req_size = 4
// ----------------------------------------------------------------------------
`ifndef INC_L1I_TOP
`define INC_L1I_TOP

module l1i_top 
(
	input 													clk,
	input 													rst_n,
	input 													core_req_val,
	input 	[`CORE_ADDR_WIDTH-1:0] 	core_req_addr,
	output                        	core_req_ack,
	output	[`CORE_DATA_WIDTH-1:0] 	core_ack_data
);

	wire [`L1_LD_MEM_WIDTH-1:0] ld_rdata [`L1_WAY_NUM];
	wire  											ld_val 	 [`L1_WAY_NUM];
	wire [`L1_LD_TAG_WIDTH-1:0] ld_tag   [`L1_WAY_NUM];



	genvar way;
	generate 
		for(way = 0; way < `L1_WAY_NUM; way = way + 1) begin: way
			
			assign {ld_val[way], ld_tag[way]} = ld_rdata[way];


			// -----------------------------------------------------
			// LD tag memories 
			// -----------------------------------------------------
			l1_reg_mem 
			#(
				.WIDTH (`L1_LD_MEM_WIDTH), 
				.DEPTH (`L1_IDX_WIDTH)
			)
			ld_mem 
			(
				.clk 		(clk),
				.rst_n 	(rst_n),
				.raddr 	(core_req_addr),
				.rdata 	(ld_rdata[way]),
				.wen 		(),
				.waddr 	(),
				.wdata 	(),
				.wbe 		()
			);

			// -----------------------------------------------------
			// Data memories
			// -----------------------------------------------------
			l1_reg_mem 
			#(
				.WIDTH (`L1_DM_WIDTH), 
				.DEPTH (`L1_IDX_WIDTH)
			)
			dm_mem 
			(
				.clk 		(clk),
				.rst_n 	(rst_n),
				.raddr 	(),
				.rdata 	(),
				.wen 		(),
				.waddr 	(),
				.wdata 	(),
				.wbe 		()
			);

	endgenerate

endmodule
`endif