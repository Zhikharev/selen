// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1i_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : core_req_cop = RD core_req_size = 4
//
// 1.0 		20.01.16  	Начальная версия со статической памятью
// 1.1    23.01.16    Исправлены ошибки
// 1.2    02.03.16    NO_L1_TRACE изменён на L1_TRACE
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
	output 		 	[`CORE_ADDR_WIDTH-1:0]	mau_req_addr,
	input 															mau_req_ack,
	input 			[`L1_LINE_SIZE-1:0] 		mau_ack_data
);

	// Для хранения первого адреса во время аппартной очистки
	// кэш-памяти после сброса
	reg  [`CORE_ADDR_WIDTH-1:0]   	core_req_addr_r;
	reg                           	core_req_val_r;
	wire                            cache_ready;
	reg                             cache_ready_r;
	// Стадия чтения
	wire [`CORE_ADDR_WIDTH-1:0]   	req_addr;
	wire [`CORE_TAG_WIDTH-1:0] 			req_tag;
	wire [`CORE_IDX_WIDTH-1:0] 			req_idx;
	wire [`CORE_OFFSET_WIDTH-1:0] 	req_offset;
	wire                          	req_val;

	// Стадия анализа
	reg  [`CORE_TAG_WIDTH-1:0] 			req_tag_r;
	reg  [`CORE_IDX_WIDTH-1:0] 			req_idx_r;
	reg  [`CORE_OFFSET_WIDTH-1:0] 	req_offset_r;
	reg                           	req_val_r;

	reg  [`L1_WAY_NUM-1:0] 					tag_cmp_vect;
	wire                            req_ack;
	wire [`L1_LINE_SIZE-1:0]        core_line_data;

	reg 														mau_req_was_send_r;
	reg 														mau_req_ack_r;
	reg  [`L1_LINE_SIZE-1:0]        mau_ack_data_r;

	wire [`L1_WAY_NUM-1:0]					ld_ready_vect;
	wire [`L1_WAY_NUM-1:0]          ld_en_vect;
	wire [`CORE_IDX_WIDTH-1:0]      ld_addr;
	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_rdata 		[`L1_WAY_NUM];
	wire [`L1_WAY_NUM-1:0] 					ld_rd_val_vect;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_rd_tag   [`L1_WAY_NUM];
	wire [`L1_WAY_NUM-1:0]          ld_we_vect;
	wire [`L1_LD_MEM_WIDTH-1:0] 		ld_wdata;
	wire  													ld_wr_val;
	wire [`CORE_TAG_WIDTH-1:0] 			ld_wr_tag;

	wire                            lru_ready;
	wire [`L1_WAY_NUM-1:0] 					lru_way_vect;
	reg  [`L1_WAY_NUM-1:0] 					lru_way_vect_r;
	wire 														lru_hit;
	wire                            lru_evict_val;
	wire [$clog2(`L1_WAY_NUM)-1:0]  lru_way_pos;

	wire [`L1_WAY_NUM-1:0]          dm_en_vect;
	wire [`L1_WAY_NUM-1:0]          dm_we_vect;
	wire [`CORE_IDX_WIDTH-1:0]      dm_addr;
	wire [`L1_LINE_SIZE-1:0]        dm_rdata [`L1_WAY_NUM];
	wire [`L1_LINE_SIZE-1:0] 				dm_wdata;

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

  // -----------------------------------------------------
	// CACHE
	// -----------------------------------------------------
	always_ff @(posedge clk) cache_ready_r <= cache_ready;
	assign req_val = cache_ready & core_req_val & (req_ack | ~cache_ready_r);
	assign req_addr = (cache_ready & ~cache_ready_r) ? core_req_addr_r : core_req_addr;
	assign {req_tag, req_idx, req_offset} = req_addr;
	always_ff @(posedge clk) if(req_val) req_tag_r    <= req_tag;
	always_ff @(posedge clk) if(req_val) req_idx_r    <= req_idx;
	always_ff @(posedge clk) if(req_val) req_offset_r <= req_offset;

	always_ff @(posedge clk, negedge rst_n) begin
		if(~rst_n) core_req_val_r <= 1'b0;
		else core_req_val_r <= core_req_val;
	end

	always_ff @(posedge clk)
		if(~core_req_val_r) core_req_addr_r <= core_req_addr;

	always @(posedge clk, negedge rst_n)
		if(~rst_n) req_val_r <= 1'b0;
		else req_val_r <= req_val;

	assign req_ack = mau_req_ack_r | lru_hit;

	assign cache_ready = &ld_ready_vect & lru_ready;

	// -----------------------------------------------------
	// LRU
	// -----------------------------------------------------
	always_ff @(posedge clk) if(req_val_r) lru_way_vect_r <= lru_way_vect;
	assign lru_way_pos = one_hot_num(lru_way_vect_r);

	// -----------------------------------------------------
	// LD
	// -----------------------------------------------------
	assign ld_en_vect = {`L1_WAY_NUM{(req_val)}} | (lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}}));
	assign ld_we_vect = lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}});
	assign ld_addr   = (req_val) ? req_idx : req_idx_r;
	assign ld_wdata  = {ld_wr_val, ld_wr_tag};
	assign ld_wr_val = 1'b1;
	assign ld_wr_tag = req_tag_r;

	// -----------------------------------------------------
	// MAU
	// -----------------------------------------------------
	always @(posedge clk, posedge rst_n) begin
		if(~rst_n) mau_req_was_send_r <= 1'b0;
		else if(mau_req_was_send_r) mau_req_was_send_r <= ~mau_req_ack;
	 	else mau_req_was_send_r <= mau_req_val;
	end
	assign mau_req_val = (req_val_r & ~lru_hit) | mau_req_was_send_r;
	assign mau_req_addr = {req_tag_r, req_idx_r, {`CORE_OFFSET_WIDTH{1'b0}}};
	always @(posedge clk) mau_req_ack_r  <= mau_req_ack;
	always @(posedge clk) mau_ack_data_r <= mau_ack_data;

	// -----------------------------------------------------
	// CORE
	// -----------------------------------------------------
	assign core_req_ack = req_ack;
	assign core_line_data = (lru_hit) ? dm_rdata[lru_way_pos] : mau_ack_data_r;
	assign core_ack_data = core_line_data[req_offset_r*8+:`CORE_DATA_WIDTH];

	// -----------------------------------------------------
	// DM
	// -----------------------------------------------------
	assign dm_en_vect = {`L1_WAY_NUM{(req_val)}} | (lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}}));
	assign dm_we_vect = lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}});
	assign dm_addr  = (req_val) ? req_idx : req_idx_r;
	assign dm_wdata = mau_ack_data;
	assign dm_wr_be = '1;

	genvar way;
	generate
		for(way = 0; way < `L1_WAY_NUM; way = way + 1) begin

			assign {ld_rd_val_vect[way], ld_rd_tag[way]} = ld_rdata[way];
			assign tag_cmp_vect[way] = (ld_rd_tag[way] == req_tag_r);

			// -----------------------------------------------------
			// LD tag memories
			// -----------------------------------------------------
			l1_ld_mem
			#(
				.WIDTH (`L1_LD_MEM_WIDTH),
				.DEPTH (`L1_SET_NUM)
			)
			ld_mem
			(
				.CLK 		(clk),
				.RST_N 	(rst_n),
				.EN     (ld_en_vect[way]),
				.WE     (ld_we_vect[way]),
				.ADDR 	(ld_addr),
				.RDATA 	(ld_rdata[way]),
				.WDATA 	(ld_wdata),
				.ready  (ld_ready_vect[way])
			);

			// -----------------------------------------------------
			// Data memories
			// -----------------------------------------------------

			l1_dm_mem
			#(
				.WIDTH (`L1_LD_MEM_WIDTH),
				.DEPTH (`L1_SET_NUM)
			)
			dm_mem
			(
				.CLK 		(clk),
				.EN 		(dm_en_vect[way]),
				.ADDR 	(dm_addr),
				.WE 		(dm_we_vect[way]),
				.WDATA 	(dm_wdata),
				.RDATA  (dm_rdata[way])
			);
		end
	endgenerate

	l1_lrum lrum
	(
		.clk 					(clk),
		.rst_n 				(rst_n),
		.req 					(req_val),
 		.idx 					(req_idx),
 		.ready        (lru_ready),
  	.tag_cmp_vect (tag_cmp_vect),
  	.ld_val_vect  (ld_rd_val_vect),
		.hit 					(lru_hit),
		.evict_val   	(lru_evict_val),
		.way_vect 		(lru_way_vect)
	);

	// -----------------------------------------------------------
	// ASSERTIONS
	// -----------------------------------------------------------

	`ifndef NO_L1_ASSERTIONS
		wire tag_cmp_with_val_vect;
		assign tag_cmp_with_val_vect = tag_cmp_vect & ld_rd_val_vect;

		`ASSERT_ONE_HOT(tag_cmp_with_val_vect, req_val_r)
		`ASSERT_ONE_HOT(lru_way_vect, req_val_r)

		offset_allign_p:
			assert property(@(posedge clk) (core_req_val & rst_n) -> core_req_addr[1:0] == 0)
			else $fatal("Wrong offset allignment!");
	`endif

	// -----------------------------------------------------------
	// TRACER
	// -----------------------------------------------------------
	`ifdef L1_TRACE

		// LD
		initial begin
			string str;
			$timeformat(-9, 1, " ns", 0);
			forever begin
				@(posedge clk);
				if(rst_n) begin
					if(core_req_val) begin
						str = $sformatf("L1I ld tag=%0h idx=%0h ", core_req_tag, core_req_idx);
						if(lru_hit) str = {str, $sformatf("hit way=%0d data=%0h", lru_way_pos, dm_rdata[lru_way_pos])};
						else str = {str, $sformatf("miss I->S way=%0d", lru_way_pos)};
						$display("%0s (%0t)", str, $time());
						if(lru_evict_val) begin
							str = $sformatf("L1I EVICT way=%0d tag=%0h idx=%0h ", lru_way_pos, ld_rd_tag[lru_way_pos], core_req_idx);
							$display("%0s (%0t)", str, $time());
						end
						if(!lru_hit) do begin @(posedge clk); end while(!core_req_ack);
					end
				end
			end
		end

		// DM
		initial begin
			string str;
			forever begin
				@(posedge clk);
				if(rst_n) begin
					if(dm_we_vect != 0) begin
						str = $sformatf("L1I dm write idx=%0h way=%0d data=%0h",
						core_req_idx, one_hot_num(dm_we_vect), dm_wdata);
						$display("%0s (%0t)", str, $time());
					end
				end
			end
		end
	`endif
endmodule
`endif