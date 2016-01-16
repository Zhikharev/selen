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

	localparam IDLE 			= 1'b0;
	localparam TR_REQ 		= 1'b1;
	localparam REC_ACK    = 1'b1;

	localparam TR_CNT_MAX = `L1_LINE_SIZE/`CORE_DATA_WIDTH;

	localparam ACK_I  = 1'b0;
	localparam ACK_D  = 1'b1;

	localparam BUF_WIDTH = $clog2(TR_CNT_MAX) + 2;

	wire rst_n;

	reg [`CORE_DATA_WIDTH-1:0] wb_dat_r;
	reg [`CORE_ADDR_WIDTH-1:0] wb_adr_r;
	reg                        wb_cyc_r;
	reg [`CORE_BE_WIDTH-1:0]   wb_sel_r;
	reg                        wb_stb_r;
	reg                        wb_we_r;

	wire [`CORE_DATA_WIDTH-1:0] wb_dat;
	wire [`CORE_ADDR_WIDTH-1:0] wb_adr;
	wire                        wb_cyc;
	wire [`CORE_BE_WIDTH-1:0]   wb_sel;
	wire                        wb_stb;
	wire                        wb_we;

	reg [`CORE_ADDR_WIDTH-1:0] 		tr_addr_r;
	reg [`CORE_ADDR_WIDTH-1:0] 		tr_addr_next;
	reg [$clog2(TR_CNT_MAX)-1:0] 	tr_cnt_r;
	reg [$clog2(TR_CNT_MAX)-1:0]  tr_cnt_next;
	reg [0:0]											tr_state_r;
	reg [0:0]											tr_state_next;


	reg  													ack_received;
	wire 													ack_wait;
	wire 													wait_ack_type;
	wire 													wait_ack_we;
	wire [$clog2(TR_CNT_MAX)-1:0] wait_ack_cnt;
	wire [BUF_WIDTH-1:0] 					wait_ack;
	wire 													ack_type;
	wire 													ack_we;
	wire [$clog2(TR_CNT_MAX)-1:0] ack_cnt;
	wire [BUF_WIDTH-1:0] 					ack;
	wire 													ack_waiting;
	wire 													ack_waiting_n;
	wire 													buf_full;


	reg ack_state_r;
	reg ack_state_next;
	reg  [`L1_LINE_SIZE-1:0] ack_data_r;
	wire [`L1_LINE_SIZE-1:0] ack_data_next;
	reg  [$clog2(TR_CNT_MAX)-1:0] ack_cnt_r;
	reg  [$clog2(TR_CNT_MAX)-1:0] ack_cnt_next;

	wire i_val;
	reg  i_req_was_send_r;

	wire d_val;
	reg  d_req_was_send_r;

	assign rst_n = ~wb_rst_i;
	assign ack_waiting = ~ack_waiting_n;

	// -----------------------------------------------------
	// Inner val
	// -----------------------------------------------------

	assign d_val = l1d_req_val & ~d_req_was_send_r & ~buf_full;
	assign i_val = l1i_req_val & ~i_req_was_send_r & ~buf_full;

	always @(posedge wb_clk_i) begin
		if(d_req_was_send_r) d_req_was_send_r <= ~((ack_received & (ack_type == ACK_D)) & (ack_we == 1'b0));
		else d_req_was_send_r <= l1d_req_val & ~l1d_req_we & (tr_state_r == IDLE) & ~buf_full;
	end

	always @(posedge wb_clk_i) begin
		if(i_req_was_send_r) i_req_was_send_r <= ~(ack_received & (ack_type == ACK_I));
		else i_req_was_send_r <= l1i_req_val & ~l1d_req_val & (tr_state_r == IDLE) & ~buf_full;
	end

	// -----------------------------------------------------
	// BUF
	// -----------------------------------------------------

	assign wait_ack = {wait_ack_type, wait_ack_we, wait_ack_cnt};
	assign {ack_type, ack_we, ack_cnt} = ack;

	fifo 
	#(
		.WIDTH (BUF_WIDTH),
		.DEPTH (2)
	) 
	ack_type_q
	(
  	.clk 		(wb_clk_i), 
  	.rst 		(wb_rst_i),
  	.rd 		(ack_received), 
  	.wr 		(ack_wait),
  	.w_data (wait_ack),
  	.empty 	(ack_waiting_n), 
  	.full 	(buf_full),
  	.r_data (ack)
	);

	// -------------------------------------------------------------
	// REQ PROCESSING
	// -------------------------------------------------------------

	assign wb_cyc = ack_waiting;
	assign wb_adr = tr_addr_r;
	assign wb_stb = (tr_state_r == TR_REQ);
	assign wb_adr = tr_addr_r;
	assign wb_we  = l1d_req_we;
	assign wb_sel = l1d_req_be;
	assign wb_dat = l1d_req_wdata;

	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			tr_state_r  <= IDLE;
		end
		else begin
			tr_state_r  <= tr_state_next;
		end
	end

	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			tr_addr_r <= 0;
			tr_cnt_r 	<= 0;
		end
		else begin
			tr_addr_r <= tr_addr_next;
			tr_cnt_r  <= tr_cnt_next;
		end
	end

	assign ack_wait = i_val | d_val;;
	assign wait_ack_type = (d_val) ? ACK_D : ACK_I;
	assign wait_ack_cnt  = (d_val & l1d_req_nc) ? 0 : TR_CNT_MAX - 1;
	assign wait_ack_we   = (d_val & l1d_req_we) ? 1'b1 : 1'b0;

	always @* begin
		case(tr_state_r)
			IDLE: begin
				if(d_val) begin
					tr_state_next = TR_REQ;
					tr_addr_next = l1d_req_addr;
					if(l1d_req_nc) tr_cnt_next = 0;
					else           tr_cnt_next = TR_CNT_MAX - 1;
				end
				else if(i_val) begin
					tr_state_next = TR_REQ;
					tr_cnt_next  = TR_CNT_MAX - 1;
					tr_addr_next = l1i_req_addr;
				end
				else begin
					tr_state_next = IDLE;
					tr_addr_next = tr_addr_r;
					tr_cnt_next  = tr_cnt_r;
				end
			end
			TR_REQ: begin
				if(tr_cnt_r == 0) begin
						tr_state_next = IDLE;
						tr_addr_next = tr_addr_r;
						tr_cnt_next  = tr_cnt_r;
				end
				else begin
					tr_state_next = TR_REQ;
					if(~wb_stall_i) begin
						tr_addr_next = tr_addr_r + `CORE_DATA_WIDTH/8;
						tr_cnt_next  = tr_cnt_r - 1'b1;
					end
					else begin
						tr_addr_next = tr_addr_r;
						tr_cnt_next  = tr_cnt_r;
					end
				end
			end
		endcase
	end

	// -------------------------------------------------------------
	// ACK PROCESSING
	// -------------------------------------------------------------

	assign l1i_req_ack = ack_received & (ack_type == ACK_I);
	assign l1d_req_ack = (l1d_req_we) ? d_val : (ack_received & (ack_type == ACK_D) & (ack_we == 1'b0));
	
	assign l1i_ack_data = ack_data_r;
	assign l1d_ack_data = ack_data_r;

	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			ack_state_r <= IDLE;
		end
		else begin
			ack_state_r <= ack_state_next;
		end
	end

	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			ack_data_r   <= 0;
		end
		else begin
			if(wb_ack_i) ack_data_r <= {wb_dat_i, ack_data_r[`L1_LINE_SIZE-1:`CORE_DATA_WIDTH]};
		end
	end


	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			ack_cnt_r <= 0;
		end
		else begin
			ack_cnt_r <= ack_cnt_next;
		end
	end

	always @* begin
		if(wb_ack_i) begin
			if(ack_state_r == IDLE)
				ack_cnt_next = ack_cnt;
			else
				ack_cnt_next = ack_cnt_r - 1;
		end
		else begin
			ack_cnt_next = ack_cnt_r;
		end
	end

	always @* begin
		case(ack_state_r)
			IDLE: begin
				ack_received = 0;
				if(wb_ack_i) 	ack_state_next = REC_ACK;
				else 					ack_state_next = IDLE;
			end
			REC_ACK: begin
				if(ack_cnt_r == 0) begin
					ack_received = 1;
					ack_state_next = IDLE;
				end
				else begin
					ack_state_next = REC_ACK;
					ack_received = 0;
				end
			end
		endcase
	end

	// -------------------------------------------------------------
	// WISHBONE REGISTERS AND OUTPUT
	// -------------------------------------------------------------

	always @(posedge wb_clk_i or negedge rst_n) begin
		if(~rst_n) begin
			wb_dat_r <= 0;
			wb_adr_r <= 0;
			wb_cyc_r <= 0;
			wb_sel_r <= 0;
			wb_stb_r <= 0;
			wb_we_r  <= 0;
		end
		else begin
			wb_dat_r <= wb_dat;
			wb_adr_r <= wb_adr;
			wb_cyc_r <= wb_cyc;
			wb_sel_r <= wb_sel;
			wb_stb_r <= wb_stb;
			wb_we_r  <= wb_we;
		end
	end

	assign wb_dat_o = wb_dat_r;
	assign wb_adr_o = wb_adr_r;
	assign wb_cyc_o = wb_cyc_r;
	assign wb_sel_o = wb_sel_r;
	assign wb_stb_o = wb_stb_r;
	assign wb_we_o  = wb_we_r;

	// -----------------------------------------------------------
	// ASSERTIONS
	// -----------------------------------------------------------



endmodule

`endif