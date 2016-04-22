// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : l1_mau.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_MAU
`define INC_L1_MAU

module l1_mau
(

	// L1I interface
	input	 												l1i_req_val,
	input  [`CORE_ADDR_WIDTH-1:0]	l1i_req_addr,
	output 												l1i_req_ack,
	output [`L1_LINE_SIZE-1:0] 		l1i_ack_data,

	// L1D interface
	input	 												l1d_req_val,
	input                         l1d_req_nc,
	input                       	l1d_req_we,
	input  [`CORE_ADDR_WIDTH-1:0]	l1d_req_addr,
	input  [`CORE_DATA_WIDTH-1:0] l1d_req_wdata,
	input  [`CORE_BE_WIDTH-1:0]   l1d_req_be,
	output 												l1d_req_ack,
	output [`L1_LINE_SIZE-1:0] 		l1d_ack_data,
	output                        l1d_ack_nc,
	output                        l1d_ack_we,

	// Wishbone B4 interface
	input 											 	wb_clk_i,
	input 											 	wb_rst_i,
	input  [`CORE_DATA_WIDTH-1:0] wb_dat_i,
	output [`CORE_DATA_WIDTH-1:0] wb_dat_o,
	input 											 	wb_ack_i,
	output [`CORE_ADDR_WIDTH-1:0] wb_adr_o,
	output                       	wb_cyc_o,
	input                        	wb_stall_i,
	input                        	wb_err_i, 	// not used now
	output                      	wb_lock_o, 	// not used now
	input                        	wb_rty_i, 	// not used now
	output [`CORE_BE_WIDTH-1:0]   wb_sel_o,
	output                       	wb_stb_o,
	output                       	wb_tga_o, 	// not used now
	output                       	wb_tgc_o, 	// not used now
	output                       	wb_we_o
);

	// -----------------------------------------------------
	// ARBITRATION
	// REQ BUF
	// -----------------------------------------------------

	localparam REQ_HDR_BUF_WIDTH = (1 + 1 + `CORE_ADDR_WIDTH + `CORE_BE_WIDTH);

	wire 													req_wr;
	wire 													req_nc;
	wire [`CORE_ADDR_WIDTH-1:0] 	req_addr;
	wire [`CORE_BE_WIDTH-1:0]   	req_be;
	wire [`CORE_DATA_WIDTH-1:0] 	req_wdata;
	wire [REQ_HDR_BUF_WIDTH-1:0]  req_hdr_data;

	wire                          req_hdr_val;
	wire                          req_hdr_finished;

	wire                          req_dat_val;
	wire                          req_dat_finished;

	wire                          req_ack;

	wire [REQ_HDR_BUF_WIDTH-1:0]  tr_hdr_data;
	wire 													tr_wr;
	wire 													tr_nc;
	wire [`CORE_ADDR_WIDTH-1:0] 	tr_addr;
	wire [`CORE_BE_WIDTH-1:0]   	tr_be;
	wire [`CORE_DATA_WIDTH-1:0] 	tr_wdata;

	wire                        	req_hdr_buf_full;
	wire                        	req_hdr_buf_empty;

	wire                        	req_dat_buf_full;
	wire                        	req_dat_buf_empty;

	wire 													req_d_val;
	wire 													req_i_val;
	reg                           d_req_rd_accepted_r;
	reg                           i_req_rd_accepted_r;

	localparam ACK_BUF_WIDTH = $clog2(TR_CNT_MAX) + 1 + 1 + 1;
	localparam ACK_I  = 1'b0;
	localparam ACK_D  = 1'b1;

	wire 													w_ack_type;
	wire 													w_ack_wr;
	wire                          w_ack_nc;
	wire [$clog2(TR_CNT_MAX)-1:0] w_ack_cnt;
	wire [ACK_BUF_WIDTH-1:0] 			w_ack_data;

	wire 													ack_type;
	wire 													ack_wr;
	wire                          ack_nc;
	wire [$clog2(TR_CNT_MAX)-1:0] ack_cnt;
	wire [ACK_BUF_WIDTH-1:0] 			ack_data;

	reg 													ack_type_r;
	reg 													ack_wr_r;
	reg                          	ack_nc_r;

	wire                          w_ack;
	wire                          r_ack;

	wire                          ack_buf_full;
	wire                          ack_buf_empty;

	localparam TR_IDLE 		= 1'b0;
	localparam TR_REQ 		= 1'b1;
	localparam TR_CNT_MAX = `L1_LINE_SIZE/`CORE_DATA_WIDTH;

	reg [0:0]											tr_state_r;
	reg [0:0]											tr_state_next;
	reg [`CORE_ADDR_WIDTH-1:0] 		tr_addr_r;
	reg [`CORE_ADDR_WIDTH-1:0] 		tr_addr_next;
	reg [$clog2(TR_CNT_MAX)-1:0] 	tr_cnt_r;
	reg [$clog2(TR_CNT_MAX)-1:0]  tr_cnt_next;

	localparam ACK_IDLE 	= 1'b0;
	localparam ACK_REC 		= 1'b1;

	reg 													ack_state_r;
	reg 													ack_state_next;
	reg  [`L1_LINE_SIZE-1:0] 			ack_data_r;
	reg  [$clog2(TR_CNT_MAX)-1:0] ack_cnt_r;
	reg  [$clog2(TR_CNT_MAX)-1:0] ack_cnt_next;

	// Arbitration

	assign req_d_val = l1d_req_val & ~req_hdr_buf_full & (~req_dat_buf_full | ~l1d_req_we) &
										~d_req_rd_accepted_r & ~ack_buf_full;

	assign req_i_val = l1i_req_val & ~req_hdr_buf_full & (~l1d_req_val | d_req_rd_accepted_r) &
	                   ~i_req_rd_accepted_r & ~ack_buf_full;

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if(wb_rst_i) d_req_rd_accepted_r <= 1'b0;
		else begin
			if(d_req_rd_accepted_r) d_req_rd_accepted_r <= ~(req_ack & ~ack_wr_r & (ack_type_r == ACK_D));
			else d_req_rd_accepted_r <= req_d_val & ~l1d_req_we;
		end
	end

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if(wb_rst_i) i_req_rd_accepted_r <= 1'b0;
		else begin
			if(i_req_rd_accepted_r) i_req_rd_accepted_r <= ~(req_ack & (ack_type_r == ACK_I));
			else i_req_rd_accepted_r <= req_i_val;
		end
	end

	// Header buffer

	assign req_hdr_val  = req_d_val | req_i_val;
	assign req_hdr_data = {req_wr, req_nc, req_be, req_addr};
	assign {tr_wr, tr_nc, tr_be, tr_addr} = tr_hdr_data;

	sync_fifo
	#(
		.DWIDTH (REQ_HDR_BUF_WIDTH),
		.AWIDTH (2)
	)
	req_hdr_buf
	(
  	.clk 				(wb_clk_i),
  	.rst 				(wb_rst_i),
  	.fifo_re 		(req_hdr_finished),
  	.fifo_we 		(req_hdr_val),
  	.fifo_wd 		(req_hdr_data),
  	.fifo_empty (req_hdr_buf_empty),
  	.fifo_full 	(req_hdr_buf_full),
  	.fifo_rd 		(tr_hdr_data)
	);

	// Data buffer

	assign req_dat_val = req_d_val & req_wr;

	sync_fifo
	#(
		.DWIDTH (`CORE_DATA_WIDTH),
		.AWIDTH (1)
	)
	req_data_buf
	(
  	.clk 				(wb_clk_i),
  	.rst 				(wb_rst_i),
  	.fifo_re 		(req_dat_finished),
  	.fifo_we 		(req_dat_val),
  	.fifo_wd 		(req_wdata),
  	.fifo_empty (req_dat_buf_empty),
  	.fifo_full 	(req_dat_buf_full),
  	.fifo_rd 		(tr_wdata)
	);

	assign req_wdata = l1d_req_wdata;
	assign req_wr    = req_d_val & l1d_req_we;
	assign req_be    = l1d_req_be;
	assign req_nc    = req_d_val & l1d_req_nc;
	assign req_addr  = (req_d_val) ? l1d_req_addr : l1i_req_addr;

	// ACK buffer

	assign w_ack_data = {w_ack_type, w_ack_wr, w_ack_nc, w_ack_cnt};
	assign {ack_type, ack_wr, ack_nc, ack_cnt} = ack_data;

	assign w_ack 		  = req_d_val | req_i_val;
	assign w_ack_type = (req_d_val) ? ACK_D : ACK_I;
	assign w_ack_cnt  = (req_d_val & (req_nc | req_wr)) ? 0 : TR_CNT_MAX - 1;
	assign w_ack_wr   = req_d_val & req_wr;
	assign w_ack_nc   = req_d_val & req_nc;

	assign r_ack   = (ack_state_next == ACK_REC) & (ack_cnt_next == 1'b0);

	assign req_ack = (ack_state_r == ACK_REC) & (ack_cnt_r == 0);

	always @(posedge wb_clk_i) begin
		if(r_ack) begin
			ack_type_r <= ack_type;
			ack_nc_r   <= ack_nc;
			ack_wr_r   <= ack_wr;
		end
	end

	sync_fifo
	#(
		.DWIDTH (ACK_BUF_WIDTH),
		.AWIDTH (2)
	)
	ack_buff
	(
  	.clk 				(wb_clk_i),
  	.rst 				(wb_rst_i),
  	.fifo_re 		(r_ack),
  	.fifo_we 		(w_ack),
  	.fifo_wd 		(w_ack_data),
  	.fifo_empty	(ack_buf_empty),
  	.fifo_full 	(ack_buf_full),
  	.fifo_rd 		(ack_data)
	);

	// -------------------------------------------------------------
	// TR PROCESSING
	// -------------------------------------------------------------

	assign req_hdr_finished = (tr_state_r == TR_REQ) & (tr_cnt_r == 0) & ~wb_stall_i;
	assign req_dat_finished = (tr_state_r == TR_REQ) & (tr_cnt_r == 0) & ~wb_stall_i & tr_wr;

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if(wb_rst_i) begin
			tr_state_r <= TR_IDLE;
			tr_addr_r  <= 0;
			tr_cnt_r 	 <= 0;
		end
		else begin
			tr_state_r <= tr_state_next;
			tr_addr_r  <= tr_addr_next;
			tr_cnt_r   <= tr_cnt_next;
		end
	end

	always @* begin
		case(tr_state_r)
			TR_IDLE: begin
				if(~req_hdr_buf_empty) begin
					tr_state_next = TR_REQ;
					tr_addr_next = tr_addr;
					if(tr_nc | tr_wr) tr_cnt_next = 0;
					else tr_cnt_next = TR_CNT_MAX - 1;
				end
				else begin
					tr_state_next = TR_IDLE;
					tr_addr_next = tr_addr_r;
					tr_cnt_next  = tr_cnt_r;
				end
			end
			TR_REQ: begin
				if(wb_stall_i) begin
					tr_state_next = TR_REQ;
					tr_addr_next = tr_addr_r;
					tr_cnt_next  = tr_cnt_r;
				end
				else begin
					if(tr_cnt_r == 0) begin
						tr_state_next = TR_IDLE;
						tr_addr_next = tr_addr_r;
						tr_cnt_next  = tr_cnt_r;
					end
					else begin
						tr_state_next = TR_REQ;
						tr_addr_next = tr_addr_r + `CORE_DATA_WIDTH/8;
						tr_cnt_next  = tr_cnt_r - 1'b1;
					end
				end
			end
		endcase
	end

	// -------------------------------------------------------------
	// ACK PROCESSING
	// -------------------------------------------------------------

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if(wb_rst_i) begin
			ack_state_r <= ACK_IDLE;
			ack_cnt_r <= 0;
		end
		else begin
			ack_state_r <= ack_state_next;
			ack_cnt_r <= ack_cnt_next;
		end
	end

	always @* begin
		case(ack_state_r)
			ACK_IDLE: begin
				if(wb_ack_i) begin
					ack_state_next = ACK_REC;
					ack_cnt_next = ack_cnt;
				end
				else begin
					ack_state_next = ACK_IDLE;
					ack_cnt_next = ack_cnt_r;
				end
			end
			ACK_REC: begin
				if(ack_cnt_r == 0) begin
					if(wb_ack_i) begin
						ack_state_next = ACK_REC;
						ack_cnt_next = ack_cnt;
					end
					else begin
						ack_state_next = ACK_IDLE;
						ack_cnt_next = ack_cnt_r;
					end
				end
				else begin
					ack_state_next = ACK_REC;
					if(wb_ack_i) ack_cnt_next = ack_cnt_r - 1;
					else ack_cnt_next = ack_cnt_r;
				end
			end
		endcase
	end

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
		if(wb_rst_i) begin
			ack_data_r   <= 0;
		end
		else begin
			if(wb_ack_i) ack_data_r <= {wb_dat_i, ack_data_r[`L1_LINE_SIZE-1:`CORE_DATA_WIDTH]};
		end
	end

	assign wb_cyc_o = ~ack_buf_empty;
	assign wb_stb_o = (tr_state_r == TR_REQ);
	assign wb_adr_o = tr_addr_r;
	assign wb_we_o  = tr_wr;
	assign wb_sel_o = tr_be;
	assign wb_dat_o = tr_wdata;

	assign l1i_req_ack = req_ack & (ack_type_r == ACK_I);
	assign l1i_ack_data = ack_data_r;

	assign l1d_req_ack = (w_ack & w_ack_wr) | (req_ack & (ack_type_r == ACK_D) & ~ack_wr_r);
	assign l1d_ack_data = ack_data_r;
	assign l1d_ack_nc 	= (w_ack & w_ack_wr & w_ack_nc) | ack_nc_r;
	assign l1d_ack_we   = w_ack_wr;

endmodule
`endif