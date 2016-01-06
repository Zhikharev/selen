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
	input                       	l1d_req_we
	input 												l1d_req_addr,
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
	output                      	wb_sel_o,
	output                       	wb_stb_o,
	output                       	wb_tga_o, 	// not used now
	output                       	wb_tgc_o, 	// not used now
	output                       	wb_we_o
);

	localparam IDLE 			= 1'b0;
	localparam TR_REQ 		= 1'b1;
	localparam TR_CNT_MAX = `L1_LINE_SIZE/`CORE_DATA_WIDTH;

	wire rst_n;

	reg [`CORE_DATA_WIDTH-1:0] wb_dat_r;
	reg [`CORE_ADDR_WIDTH-1:0] wb_adr_r;
	reg                        wb_cyc_r;
	reg                      	 wb_sel_r;
	reg                        wb_stb_r;
	reg                        wb_we_r;

	reg [`CORE_DATA_WIDTH-1:0] wb_dat;
	reg [`CORE_ADDR_WIDTH-1:0] wb_adr;
	reg                        wb_cyc;
	reg                      	 wb_sel;
	reg                        wb_stb;
	reg                        wb_we;

	reg [`CORE_ADDR_WIDTH-1:0] 	tr_addr_r;
	reg [`CORE_ADDR_WIDTH-1:0] 	tr_addr_next;
	reg [`MAU_TR_CNT_WIDTH-1:0] tr_cnt_r;
	reg tr_state_r;
	reg tr_state_next;

	assign rst_n = ~wb_rst_i;

	always @(posedge wb_clk or negedge rst_n) begin
		if(~rst_n) begin
			tr_state_r <= IDLE;
		end
		else begin
			tr_state_r <= tr_state_next;
		end
	end

	always @(posedge wb_clk or negedge rst_n) begin
		if(~rst_n) begin
			tr_addr_r <= 0;
		end
		else begin
			tr_addr_r <= tr_addr_next;
		end
	end

	always @* begin
		case(tr_state_r)
			IDLE: begin
				if(mau_fifo_empty) tr_state_next = IDLE;
				else begin 
					tr_state_next = TR_REQ;
					tr_addr_next  = mau_fifo_data;
				end
			end
			TR_REQ: begin
				if(tr_cnt_r == TR_CNT_MAX) begin
					if(mau_fifo_empty) tr_state_next = IDLE;
					else begin 
						tr_state_next = TR_REQ;
						tr_addr_next  = mau_fifo_data;
					end
				end
				else begin
					tr_state_next = TR_REQ;
					tr_addr_next = tr_addr_r + `CORE_DATA_WIDTH/8;
				end
			end
		endcase
	end

	always @(posedge wb_clk or negedge rst_n) begin
		if(~rst_n) begin
			tr_cnt_r <= 0;
			wb_dat_r <= 0;
			wb_adr_r <= 0;
			wb_cyc_r <= 0;
			wb_sel_r <= 0;
			wb_stb_r <= 0;
			wb_we_r  <= 0;
		end
		else begin
			if(tr_state_r == TR_REQ) 
				tr_cnt_r <= tr_cnt_r + 1'b1;
		end
	end

	assign wb_dat_o = wb_dat_r;
	assign wb_adr_o = wb_adr_r;
	assign wb_cyc_o = wb_cyc_r;
	assign wb_sel_o = wb_sel_r;
	assign wb_stb_o = wb_stb_r;
	assign wb_we_o  = wb_we_r;

endmodule

`endif