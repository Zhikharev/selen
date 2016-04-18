// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1d_top.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : write-through, no-write-allocate
//
// 1.0 		23.01.16  	Начальная версия со статической памятью
// 1.1    30.03.16    Исправлена отработка записей. Получается
//                    большая задержка, 3 такта
// 1.2    31.03.16    Улучшена обработка записей, задержка 1 такт
// 1.3    03.04.16    Исправлены ошибки связанные с отработкой записей и
//                    некэшруемых зпросов. Исправлена логи для отработки
//                    конвейерных запросов
// ----------------------------------------------------------------------------
`ifndef INC_L1D_TOP
`define INC_L1D_TOP

module l1d_top
(
	input 															clk,
	input 															rst_n,
	input 															core_req_val,
	input 		 [`CORE_ADDR_WIDTH-1:0] 	core_req_addr,
	input 		 [`CORE_COP_WIDTH-1:0]   	core_req_cop,
	input 		 [`CORE_DATA_WIDTH-1:0] 	core_req_wdata,
	input 	 	 [`CORE_SIZE_WIDTH-1:0]  	core_req_size,
	output                        			core_req_ack,
	output reg [`CORE_DATA_WIDTH-1:0] 	core_ack_data,
	output	 														mau_req_val,
	output                         			mau_req_nc,
	output                       				mau_req_we,
	output 	   [`CORE_ADDR_WIDTH-1:0]		mau_req_addr,
	output     [`CORE_DATA_WIDTH-1:0] 	mau_req_wdata,
	output reg [`CORE_BE_WIDTH-1:0]     mau_req_be,
	input 															mau_req_ack,
	input                               mau_ack_nc,
	input                               mau_ack_we,
	input 		 [`L1_LINE_SIZE-1:0] 			mau_ack_data
);

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

  wire 														cache_ready;

	wire [`CORE_TAG_WIDTH-1:0] 			req_tag;
	wire [`CORE_IDX_WIDTH-1:0] 			req_idx;
	wire [`CORE_OFFSET_WIDTH-1:0] 	req_offset;
  reg  [`L1_LINE_SIZE/8-1:0]      req_be;
	wire                          	req_val;
	reg                             req_was_send_r;

	wire 														core_req_nc;
	wire 														core_req_wr;
	wire 														core_req_rd;

  reg 											 			del_buf_val_r;
  reg [`CORE_ADDR_WIDTH-1:0] 			del_buf_addr_r;
  reg [`CORE_DATA_WIDTH-1:0] 			del_buf_data_r;
  reg                             del_buf_hit_r;
  reg [`L1_LINE_SIZE/8-1:0]       del_buf_be_r;
  reg [`L1_WAY_NUM-1:0]           del_buf_way_vect_r;
  reg                             del_buf_way_val_r;
	wire [`CORE_TAG_WIDTH-1:0] 			del_buf_tag;
	wire [`CORE_IDX_WIDTH-1:0] 			del_buf_idx;
	wire [`CORE_OFFSET_WIDTH-1:0] 	del_buf_offset;
	wire                            del_buf_clean;
	wire                            del_buf_dm_access;

  reg  [`CORE_ADDR_WIDTH-1:0]     req_addr_r;
	reg  [`CORE_TAG_WIDTH-1:0] 			req_tag_r;
	reg  [`CORE_IDX_WIDTH-1:0] 			req_idx_r;
	reg  [`CORE_OFFSET_WIDTH-1:0] 	req_offset_r;
	reg  [`CORE_DATA_WIDTH-1:0] 		req_wdata_r;
	reg                             req_we_r;
	reg                             req_nc_r;
	reg                           	req_val_r;

	reg  [`L1_WAY_NUM-1:0] 					tag_cmp_vect;
	wire                            req_ack;
	wire [`L1_LINE_SIZE-1:0]        core_line_data;

	reg 														mau_req_was_send_r;
	reg 														mau_req_ack_r;
	reg  [`L1_LINE_SIZE-1:0]        mau_ack_data_r;
	reg      												mau_ack_nc_r;

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

	wire                            lru_req;
	wire                            lru_ready;
	wire [`L1_WAY_NUM-1:0] 					lru_way_vect;
	reg  [`L1_WAY_NUM-1:0] 					lru_way_vect_r;
	wire 														lru_hit;
	wire                            lru_evict_val;
	wire [$clog2(`L1_WAY_NUM)-1:0]  lru_way_pos;

	reg  [`L1_WAY_NUM-1:0]          dm_en_vect;
	reg  [`L1_WAY_NUM-1:0]          dm_we_vect;
	reg  [`CORE_IDX_WIDTH-1:0]      dm_addr;
	reg  [`L1_LINE_SIZE-1:0]        dm_rdata [`L1_WAY_NUM];
	reg  [`L1_LINE_SIZE-1:0] 				dm_wdata;
	wire [`L1_LINE_SIZE/8-1:0]      dm_wr_be;

  // -----------------------------------------------------
	// CACHE
	// -----------------------------------------------------
	assign core_req_nc = (core_req_cop == `CORE_REQ_RDNC) | (core_req_cop == `CORE_REQ_WRNC);
	assign core_req_wr = (core_req_cop == `CORE_REQ_WR);
	assign core_req_rd = (core_req_cop == `CORE_REQ_RD);

	assign cache_ready = &ld_ready_vect & lru_ready;

  // -----------------------------------------------------
	// REQ
	// -----------------------------------------------------

	assign req_val = core_req_val & (~req_was_send_r | req_ack);

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			req_was_send_r <= 1'b0;
		end else begin
			req_was_send_r <= core_req_val &  ~req_ack;
		end
	end

	assign {req_tag, req_idx, req_offset} = core_req_addr;

	always @* begin
		if     (core_req_size == 1) req_be = 4'b0001 << req_offset;
		else if(core_req_size == 2) req_be = 4'b0011 << req_offset;
		else                        req_be = 4'b1111 << req_offset;
	end

	always @(posedge clk, negedge rst_n) begin
		if(~rst_n) req_val_r <= 1'b0;
		else req_val_r <= req_val;
	end

	always @(posedge clk) if(req_val) req_we_r <= (core_req_cop == `CORE_REQ_WRNC) | (core_req_cop == `CORE_REQ_WR);
	always @(posedge clk) if(req_val) req_nc_r <= core_req_nc;
	always @(posedge clk) if(req_val) req_addr_r <= core_req_addr;
	always @(posedge clk) if(req_val) req_wdata_r <= core_req_wdata;
	assign {req_tag_r, req_idx_r, req_offset_r} = req_addr_r;

	assign req_ack = lru_hit | del_buf_hit_r | (req_val_r & req_we_r) | mau_req_ack_r;

  // -----------------------------------------------------
	// DELAYED BUFFER
	// -----------------------------------------------------

	assign del_buf_clean = (~mau_req_ack | mau_ack_nc) &
	                       (~core_req_val | (core_req_val & core_req_nc));

	assign del_buf_dm_access = (core_req_val & core_req_wr) |
														 (core_req_val & core_req_nc) |
														 ~core_req_val;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			del_buf_val_r <= 1'b0;
			del_buf_hit_r <= 1'b0;
		end else begin
			del_buf_val_r <= (core_req_val & core_req_wr) | (~del_buf_clean & del_buf_val_r);
			del_buf_hit_r <= del_buf_val_r & req_val & core_req_rd & (del_buf_addr_r == core_req_addr);
		end
	end

	always_ff @(posedge clk) begin
		if(core_req_val & core_req_wr) begin
				del_buf_addr_r <= core_req_addr;
				del_buf_data_r <= core_req_wdata;
				del_buf_be_r   <= req_be;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			del_buf_way_val_r <= 1'b0;
		end else begin
			del_buf_way_val_r <= ~del_buf_dm_access & del_buf_val_r;
		end
	end

	always_ff @(posedge clk) begin
		if(req_val_r & ~del_buf_dm_access) begin
			del_buf_way_vect_r <= lru_way_vect;
		end
	end

	assign {del_buf_tag, del_buf_idx, del_buf_offset} = del_buf_addr_r;

	// -----------------------------------------------------
	// LRU
	// -----------------------------------------------------
	assign lru_req = req_val & (~core_req_nc);
	always_ff @(posedge clk) if(req_val_r) lru_way_vect_r <= lru_way_vect;
	assign lru_way_pos = one_hot_num(lru_way_vect);

	// -----------------------------------------------------
	// LD
	// -----------------------------------------------------
	assign ld_en_vect = {`L1_WAY_NUM{(req_val & ~core_req_nc)}} | (lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack & ~mau_ack_nc)}}));
	assign ld_we_vect = lru_way_vect_r & ({`L1_WAY_NUM{(mau_req_ack)}});
	assign ld_addr   = (req_val) ? req_idx : req_idx_r;
	assign ld_wdata  = {ld_wr_val, ld_wr_tag};
	assign ld_wr_val = 1'b1;
	assign ld_wr_tag = req_tag_r;

	// -----------------------------------------------------
	// DM
	// -----------------------------------------------------
	always @* begin
		if(req_val & core_req_rd) begin
			dm_en_vect = {`L1_WAY_NUM{1'b1}};
			dm_we_vect = {`L1_WAY_NUM{1'b0}};
			dm_addr    = req_idx;
		end
		else begin
			if(mau_req_ack & ~mau_req_nc & ~mau_req_we) begin
				dm_en_vect = lru_way_vect_r;
				dm_we_vect = lru_way_vect_r;
				dm_addr    = req_idx_r;
			end
			else begin
				if(del_buf_val_r && del_buf_way_val_r) begin
					dm_en_vect = del_buf_way_vect_r;
					dm_we_vect = del_buf_way_vect_r;
					dm_addr    = del_buf_idx;
				end
				else begin
					dm_en_vect = lru_way_vect & {`L1_WAY_NUM{del_buf_val_r}};
					dm_we_vect = lru_way_vect;
					dm_addr    = del_buf_idx;
				end
			end
		end
	end

	assign dm_wdata = (mau_req_ack & ~mau_ack_nc) ? mau_ack_data : del_buf_data_r;
	assign dm_wr_be = (mau_req_ack & ~mau_ack_nc) ? '1 : del_buf_be_r;


	// -----------------------------------------------------
	// MAU
	// -----------------------------------------------------

		always @(posedge clk, posedge rst_n) begin
			if(~rst_n) mau_req_was_send_r <= 1'b0;
			else if(mau_req_was_send_r) mau_req_was_send_r <= ~mau_req_ack | req_val_r;
	 		else mau_req_was_send_r <= mau_req_val & ~mau_req_ack;
		end

		assign mau_req_val   = (req_val_r & (core_req_nc | core_req_wr | ~lru_hit)) | mau_req_was_send_r;
		assign mau_req_nc    = req_nc_r;
    assign mau_req_we    = req_we_r;
	  assign mau_req_addr  = (req_we_r | req_nc_r) ? req_addr_r : {req_tag_r, req_idx_r, {`CORE_OFFSET_WIDTH{1'b0}}};
	 	assign mau_req_wdata = req_wdata_r;

		always @* begin
			if     (core_req_size == 1) mau_req_be = 4'b0001;
			else if(core_req_size == 2) mau_req_be = 4'b0011;
			else                        mau_req_be = 4'b1111;
		end

	always @(posedge clk) mau_req_ack_r  <= mau_req_ack & ~mau_ack_we;
	always @(posedge clk) mau_ack_data_r <= mau_ack_data;
	always @(posedge clk) mau_ack_nc_r   <= mau_ack_nc;

	// -----------------------------------------------------
	// CORE
	// -----------------------------------------------------
	assign core_req_ack   = req_ack;
	assign core_line_data = (lru_hit) ? dm_rdata[lru_way_pos] : mau_ack_data_r;

	always @* begin
		if(del_buf_hit_r) core_ack_data = del_buf_data_r;
		else if(mau_ack_nc_r) core_ack_data = core_line_data[`L1_LINE_SIZE-1:`L1_LINE_SIZE-`CORE_DATA_WIDTH];
		else core_ack_data = core_line_data[req_offset_r*8+:`CORE_DATA_WIDTH];
	end

	// -----------------------------------------------------
	// MEMORIES
	// -----------------------------------------------------

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
				.WIDTH (`L1_LINE_SIZE),
				.DEPTH (`L1_SET_NUM)
			)
			dm_mem
			(
				.CLK 		(clk),
				.EN 		(dm_en_vect[way]),
				.ADDR 	(dm_addr),
				.WE 		(dm_we_vect[way]),
				.WDATA 	(dm_wdata),
				.RDATA 	(dm_rdata[way])
			);
		end
	endgenerate


	l1_lrum lrum
	(
		.clk 					(clk),
		.rst_n 				(rst_n),
		.req 					(lru_req),
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

		no_req_when_not_ready_p:
			assert property(@(posedge clk) (core_req_val & rst_n) -> cache_ready == 1'b1)
			else $fatal("Received L1D request whenc cache is not ready!");

		no_req_val_when_mau_req_ack_p:
			assert property(@(posedge clk) (rst_n) -> $onehot0({req_val, (mau_req_ack & ~mau_ack_nc & ~mau_ack_we)}))
			else $fatal("req_val is active when mau_req_ack is active!");


		offset_allign_p:
			assert property(@(posedge clk) (core_req_val & (core_req_size == 4) & rst_n) -> core_req_addr[1:0] == 0)
			else $fatal("Wrong offset allignment! (4 bytes)");
			assert property(@(posedge clk) (core_req_val & (core_req_size == 2) & rst_n) -> core_req_addr[0] == 0)
			else $fatal("Wrong offset allignment! (2 bytes)");
	`endif

endmodule

`endif