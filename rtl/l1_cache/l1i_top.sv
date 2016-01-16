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
	input 															clk,
	input 															rst_n,
	input 															core_req_val,
	input 			[`CORE_ADDR_WIDTH-1:0] 	core_req_addr,
	output                        			core_req_ack,
	output			[`CORE_DATA_WIDTH-1:0] 	core_ack_data,
	output	 														mau_req_val,
	output reg                          mau_req_ev,
	output 			[`L1_LINE_SIZE-1:0]     mau_req_ev_data,
	output reg 	[`CORE_ADDR_WIDTH-1:0]	mau_req_addr,
	input 															mau_req_ack,
	input 			[`L1_LINE_SIZE-1:0] 		mau_ack_data
);

	wire [`CORE_TAG_WIDTH-1:0] 			core_req_tag;
	wire [`CORE_IDX_WIDTH-1:0]  		core_req_idx;
	wire [`CORE_OFFSET_WIDTH-1:0] 	core_req_offset;

	reg 														core_req_val_r;

	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_rdata 		[`L1_WAY_NUM];
	wire [`L1_WAY_NUM-1:0] 					ld_rd_val;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_rd_tag   [`L1_WAY_NUM];
	
	wire [`L1_WAY_NUM-1:0]          ld_wen_vect;
	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_wdata;
	wire  													ld_wr_val;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_wr_tag;
 
	wire [`L1_WAY_NUM-1:0] 					tag_cmp_vect;

	wire                            lru_req;
	wire [`L1_WAY_NUM-1:0] 					lru_way_vect;
	reg  [`L1_WAY_NUM-1:0] 					lru_way_vect_r;
	wire 														lru_hit;
	wire                            lru_evict_val;
	wire [$clog2(`L1_WAY_NUM)-1:0]  lru_way_pos;

	wire [`L1_LINE_SIZE-1:0]        core_line_data;

	wire [`L1_WAY_NUM-1:0]          dm_wen_vect;
	wire [`L1_LINE_SIZE-1:0]        dm_rdata [`L1_WAY_NUM];
	wire [`L1_LINE_SIZE-1:0] 				dm_wdata;
	wire [(`L1_LD_MEM_WIDTH/8)-1:0] dm_wr_be;  

	reg [1:0] 											mau_state_r;
	reg [1:0] 											mau_state_next;
	reg [`CORE_ADDR_WIDTH-1:0]			mau_req_addr_r;

	localparam MAU_IDLE  = 2'b00;
	localparam MAU_EVICT = 2'b01;
	localparam MAU_REQ   = 2'b10;

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

	always_ff @(posedge clk) core_req_val_r <= core_req_val & ~ core_req_ack;

	// -----------------------------------------------------
	// LRU
	// -----------------------------------------------------
	assign lru_req = core_req_val & ~core_req_val_r;
	always_ff @(posedge clk) if(lru_req) lru_way_vect_r <= lru_way_vect;
	
	// -----------------------------------------------------
	// MAU
	// -----------------------------------------------------
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			mau_state_r    <= MAU_IDLE;
		end else begin
			mau_state_r    <= mau_state_next;
		end
	end

	always_ff @(posedge clk) begin
		if(mau_state_r == MAU_IDLE) begin
			if(lru_evict_val)	mau_req_addr_r <= {ld_rd_tag[lru_way_pos], core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
			else mau_req_addr_r <= {core_req_tag, core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
		end
	end

	assign mau_req_val     = core_req_val & ~lru_hit;
	assign mau_req_ev_data = dm_rdata[lru_way_pos];

	always @* begin
		case(mau_state_r)
			MAU_IDLE: begin
				if(mau_req_val) begin
					if(lru_evict_val) begin
						mau_state_next = MAU_EVICT;
						mau_req_addr  = {ld_rd_tag[lru_way_pos], core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
						mau_req_ev    = 1'b1;
					end
					else begin 
						mau_state_next = MAU_REQ;
						mau_req_addr   = {core_req_tag, core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
						mau_req_ev     = 1'b0;
					end
				end
				else begin
					mau_state_next = MAU_IDLE;
					mau_req_addr   = {core_req_tag, core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
					mau_req_ev     = 1'b0;
				end
			end
			MAU_REQ: begin
				mau_req_addr   = {core_req_tag, core_req_idx, {`CORE_OFFSET_WIDTH{1'b0}}};
				mau_req_ev     = 1'b0;
				if(mau_req_ack) mau_state_next = MAU_IDLE;
				else mau_state_next = MAU_REQ;
			end
			MAU_EVICT: begin
				mau_req_addr  = mau_req_addr_r;
				mau_req_ev    = 1'b1;
				if(mau_req_ack) mau_state_next = MAU_REQ;
				else mau_state_next = MAU_EVICT;
			end
		endcase
	end

	// -----------------------------------------------------
	// CORE
	// -----------------------------------------------------
	assign core_req_ack = lru_hit | (mau_req_ack & mau_state_r == MAU_REQ);
	assign core_line_data = (lru_hit) ? dm_rdata[lru_way_pos] : mau_ack_data;

	// Request from core must be alligned to the width ofthe operation
	// We have assertion for this
	//
	// assign core_alligned_req_offset = {core_req_offset[`CORE_OFFSET_WIDTH-1:2], 2'b00};
	// assign core_ack_data = core_line_data[core_alligned_req_offset*8+:`CORE_DATA_WIDTH];

	assign core_ack_data = core_line_data[core_req_offset*8+:`CORE_DATA_WIDTH];

	// -----------------------------------------------------
	// LD
	// -----------------------------------------------------
	assign ld_wen_vect = lru_way_vect_r & ({`L1_WAY_NUM{(lru_hit | mau_req_ack)}});
	assign ld_wdata = {ld_wr_val, ld_wr_tag};
	assign ld_wr_val = 1'b1;
	assign ld_wr_tag = core_req_tag;

	// -----------------------------------------------------
	// DM
	// -----------------------------------------------------
	assign dm_wen_vect = lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}});
	assign dm_wdata = mau_ack_data;
	assign dm_wr_be = '1; //'

	genvar way;
	generate 
		for(way = 0; way < `L1_WAY_NUM; way = way + 1) begin
			
			assign {ld_rd_val[way], ld_rd_tag[way]} = ld_rdata[way];
			assign tag_cmp_vect[way] = (ld_rd_tag[way] == core_req_tag);

			// -----------------------------------------------------
			// LD tag memories 
			// -----------------------------------------------------
			l1_reg_ld_mem 
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
				.wdata 	(ld_wdata)
			);

			// -----------------------------------------------------
			// Data memories
			// -----------------------------------------------------
			l1_reg_dm_mem 
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
		.evict_val   	(lru_evict_val),
		.way_vect 		(lru_way_vect)
	);

	// -----------------------------------------------------------
	// ASSERTIONS
	// -----------------------------------------------------------

	`ifndef NO_L1_ASSERTIONS
		wire tag_cmp_with_val_vect;
		assign tag_cmp_with_val_vect = tag_cmp_vect & ld_rd_val;

		`ASSERT_ONE_HOT(tag_cmp_with_val_vect, (core_req_val & rst_n))
		`ASSERT_ONE_HOT(lru_way_vect, (core_req_val & rst_n))

		offset_allign_p:
			assert property(@(posedge clk) (core_req_val & rst_n) -> core_req_offset[1:0] == 0)
			else $fatal("Wrong offset allignment!");
	`endif

endmodule
`endif