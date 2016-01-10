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
	output	[`CORE_DATA_WIDTH-1:0] 	core_ack_data,
	output	 												mau_req_val,
	output 	[`CORE_ADDR_WIDTH-1:0]	mau_req_addr,
	input 													mau_req_ack,
	input 	[`L1_LINE_SIZE-1:0] 		mau_ack_data
);

	wire [`CORE_TAG_WIDTH-1:0] 			core_req_tag;
	wire [`CORE_IDX_WIDTH-1:0]  		core_req_idx;
	wire [`CORE_OFFSET_WIDTH-1:0] 	core_req_offset;

	reg 														core_req_val_r;
	wire 														core_req_val_next;

	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_rdata 		[`L1_WAY_NUM];
	wire [`L1_WAY_NUM-1:0] 					ld_rd_val;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_rd_tag   [`L1_WAY_NUM];
	
	wire [`L1_WAY_NUM-1:0]          ld_wen_vect;
	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_wdata;
	wire  													ld_wr_val;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_wr_tag;
	wire [(`L1_LD_MEM_WIDTH/8)-1:0] ld_wr_be;  

	wire [`L1_WAY_NUM-1:0] 					tag_cmp_vect;

	wire                            lru_req;
	wire [`L1_WAY_NUM-1:0] 					lru_way_vect;
	wire 														lru_hit;
	wire [$clog2(`L1_WAY_NUM)-1:0]  lru_way_pos;

	wire [`L1_LINE_SIZE-1:0]        core_line_data;

	wire [`L1_WAY_NUM-1:0]          dm_wen_vect;
	wire [`L1_LINE_SIZE-1:0]        dm_rdata [`L1_WAY_NUM];
	wire [`L1_LINE_SIZE-1:0] 				dm_wdata;
	wire [(`L1_LD_MEM_WIDTH/8)-1:0] dm_wr_be;  

  // ------------------------------------------------------
  // FUNCTION: one_hot_num
  // ------------------------------------------------------
  function [$clog2(`L1_WAY_NUM)-1:0] one_hot_num;
    input [`L1_WAY_NUM-1:0] one_hot_vector;
    integer i,j;
    reg [`L1_WAY_NUM-1:0] tmp;
    for(i = 0; i < $clog2(`L1_WAY_NUM); i++) begin
      for(j = 0; j < `L1_WAY_NUM; j++) begin
        tmp[j] = one_hot_vector[j] & j[i];  
      end
      one_hot_num[i] = |tmp;
    end  
  endfunction

	assign {core_req_tag, core_req_idx, core_req_offset} = core_req_addr;
	assign lru_way_pos = one_hot_num(lru_way_vect);

	// This work models like combinational circuit, VCS
	// always_ff @(posedge clk) core_req_val_r <= core_req_val & ~ core_req_ack;

	assign core_req_val_next = core_req_val & ~core_req_ack;
	always_ff @(posedge clk) core_req_val_r <= core_req_val_next;


	assign lru_req = core_req_val & ~core_req_val_r;

	// -----------------------------------------------------
	// MAU
	// -----------------------------------------------------
	assign mau_req_val  = core_req_val & ~lru_hit;
	assign mau_req_addr = {core_req_tag, core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};

	// -----------------------------------------------------
	// CORE
	// -----------------------------------------------------
	assign core_req_ack = lru_hit | mau_req_ack;
	assign core_line_data = (lru_hit) ? dm_rdata[lru_way_pos] : mau_ack_data;
	assign core_ack_data = core_line_data[core_req_offset*32+:32];

	// -----------------------------------------------------
	// LD
	// -----------------------------------------------------
	assign ld_wen_vect = lru_way_vect & ({`L1_WAY_NUM{(lru_hit | mau_req_ack)}});
	assign ld_wdata = {ld_wr_val, ld_wr_tag};
	assign ld_wr_val = 1'b1;
	assign ld_wr_tag = core_req_tag;
	assign ld_wr_be  =  '1; // '

	// -----------------------------------------------------
	// DM
	// -----------------------------------------------------
	assign dm_wen_vect = lru_way_vect & ({`L1_WAY_NUM{(mau_req_ack)}});
	assign dm_wdata = mau_ack_data;
	assign dm_wr_be = '1; //'

`ifndef NO_L1_ASSERTIONS
	wire tag_cmp_with_val_vect;
	
	assign tag_cmp_with_val_vect = tag_cmp_vect & ld_rd_val;

	`ASSERT_ONE_HOT(tag_cmp_with_val_vect, (core_req_val & rst_n))
	`ASSERT_ONE_HOT(lru_way_vect, (core_req_val & rst_n))
`endif

	genvar way;
	generate 
		for(way = 0; way < `L1_WAY_NUM; way = way + 1) begin
			
			assign {ld_rd_val[way], ld_rd_tag[way]} = ld_rdata[way];
			assign tag_cmp_vect[way] = (ld_rd_tag[way] == core_req_tag);

			// -----------------------------------------------------
			// LD tag memories 
			// -----------------------------------------------------
			l1_reg_mem 
			#(
				.WIDTH (`L1_LD_MEM_WIDTH), 
				.DEPTH ((1 << `CORE_IDX_WIDTH) + 1)
			)
			ld_mem 
			(
				.clk 		(clk),
				.rst_n 	(rst_n),
				.raddr 	(core_req_idx),
				.rdata 	(ld_rdata[way]),
				.wen 		(ld_wen_vect[way]),
				.waddr 	(core_req_idx),
				.wdata 	(ld_wdata),
				.wbe 		(ld_wr_be)
			);

			// -----------------------------------------------------
			// Data memories
			// -----------------------------------------------------
			l1_reg_mem 
			#(
				.WIDTH (`L1_LINE_SIZE), 
				.DEPTH ((1 << `CORE_IDX_WIDTH) + 1)
			)
			dm_mem 
			(
				.clk 		(clk),
				.rst_n 	(rst_n),
				.raddr 	(core_req_idx),
				.rdata 	(dm_rdata[way]),
				.wen 		(dm_wen_vect),
				.waddr 	(core_req_idx),
				.wdata 	(dm_wdata),
				.wbe 		(dm_wr_be)
			);
		end
	endgenerate

	l1_lrum lrum
	(
		.clk 					(clk),
		.rst_n 				(rst_n),
		.req 					(lru_req),
 		.idx 					(core_req_idx),
  	.tag_cmp_vect (tag_cmp_vect),
  	.ld_val_vect  (ld_rd_val),
		.hit 					(lru_hit),
		.way_vect 		(lru_way_vect)
	);

endmodule
`endif