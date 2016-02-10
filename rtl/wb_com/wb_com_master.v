// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : wb_com_master.v
// PROJECT              : Selen
// AUTHOR               : Pavel Petrakov
// AUTHOR'S EMAIL       : 
// ----------------------------------------------------------------------------
// DESCRIPTION          :   common logic for wishbone masters in wishbone
//                          commutator. Generates err_i if addr_o wasn't in
//                          s0 or s1 range.
// ----------------------------------------------------------------------------
`ifndef INC_WB_COM_MASTER
`define INC_WB_COM_MASTER

module wb_com_master
(
clk,
rst,


m_wb_addr_o,
m_wb_dat_o,
m_wb_sel_o,
m_wb_cyc_o,
m_wb_stb_o,
m_wb_we_o,

m_wb_dat_i,
m_wb_stall_i,
m_wb_ack_i,
m_wb_err_i,

time_tag,

m_to_s0_header_o,
m_to_s0_hrden,
m_to_s0_data_o,
m_to_s0_drden,
m_to_s0_hempty,

m_to_s1_header_o,
m_to_s1_hrden,
m_to_s1_data_o,
m_to_s1_drden,
m_to_s1_hempty,

s0_to_m_data_o,
s0_to_m_drden,
s0_to_m_dempty,

s1_to_m_data_o,
s1_to_m_drden,
s1_to_m_dempty
);
//main parameters
parameter   WB_ADDR_WIDTH       = 32;
parameter   WB_DATA_WIDTH       = 32;
parameter   WB_TIME_TAG         = 4;
parameter   S0_ADDR_BASE        = 32'h00000000;
parameter   S0_ADDR_MASK        = 2'b11;
parameter   S1_ADDR_BASE        = 32'h00000004;
parameter   S1_ADDR_MASK        = 2'b11;

parameter   WB_FIFO_ASIZE       = WB_TIME_TAG - 2;
parameter   WB_SEL_WIDTH        = WB_DATA_WIDTH/8;
parameter   WB_HDR_WIDTH        = WB_ADDR_WIDTH + WB_TIME_TAG + WB_SEL_WIDTH +1;
parameter   WB_M_BSCALE         = (1 << (WB_TIME_TAG-1));

input                               clk;
input                               rst;

//wb interface
input   [WB_ADDR_WIDTH - 1:0]       m_wb_addr_o;
input   [WB_DATA_WIDTH - 1:0]       m_wb_dat_o;
input   [WB_SEL_WIDTH - 1:0]        m_wb_sel_o;
input                               m_wb_cyc_o;
input                               m_wb_stb_o;
input                               m_wb_we_o;

output  [WB_DATA_WIDTH - 1:0]       m_wb_dat_i;
output                              m_wb_stall_i;
output                              m_wb_ack_i;
output                              m_wb_err_i;

input   [WB_TIME_TAG -1:0]          time_tag;

output  [WB_HDR_WIDTH - 1:0]        m_to_s0_header_o;
input                               m_to_s0_hrden;
output  [WB_DATA_WIDTH - 1:0]       m_to_s0_data_o;
input                               m_to_s0_drden;
output                              m_to_s0_hempty;

output  [WB_HDR_WIDTH - 1:0]        m_to_s1_header_o;
input                               m_to_s1_hrden;
output  [WB_DATA_WIDTH - 1:0]       m_to_s1_data_o;
input                               m_to_s1_drden;
output                              m_to_s1_hempty;

input   [WB_DATA_WIDTH - 1:0]       s0_to_m_data_o;
output                              s0_to_m_drden;
input                               s0_to_m_dempty;

input   [WB_DATA_WIDTH - 1:0]       s1_to_m_data_o;
output                              s1_to_m_drden;
input                               s1_to_m_dempty;


reg     [WB_M_BSCALE -1:0]          m_dir_sel, m_dir_fst, m_err_sel;
wire    [WB_HDR_WIDTH - 1:0]        m_to_s0_header_i, m_to_s1_header_i;
wire    [WB_DATA_WIDTH - 1:0]       m_to_s0_data_i, m_to_s1_data_i;
wire                                m_to_s0_hfull, m_to_s1_hfull;

//common master0 signals
assign m_addr_s1_hit = (m_wb_addr_o & ~({WB_ADDR_WIDTH{1'b0}} | S1_ADDR_MASK)) == S1_ADDR_BASE;
assign m_addr_s0_hit = (m_wb_addr_o & ~({WB_ADDR_WIDTH{1'b0}} | S0_ADDR_MASK)) == S0_ADDR_BASE;

always @(posedge clk)
if (rst)                                            m_dir_sel <= {WB_M_BSCALE{1'b0}};
else if (m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i)   m_dir_sel <= {m_dir_sel[6:0], m_addr_s1_hit};

always @(posedge clk)
if (rst)                                            m_err_sel <= {WB_M_BSCALE{1'b0}};
else if (m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i)   m_err_sel <= {m_err_sel[6:0], !m_addr_s1_hit & !m_addr_s0_hit};

always @(posedge clk)
if (rst)                                                                            m_dir_fst <= {WB_M_BSCALE{1'b0}};
else if ((m_wb_ack_i | m_wb_err_i) & !(m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i))    m_dir_fst <= {1'b0, m_dir_fst[WB_M_BSCALE -1:1]};
else if (m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i & !(m_wb_ack_i | m_wb_err_i))      m_dir_fst <= {m_dir_fst[WB_M_BSCALE-2:0], !(|m_dir_fst)};

wire m_arb      = |(m_dir_fst & m_dir_sel);
wire m_error    = |(m_dir_fst & m_err_sel);

assign m_wb_ack_i  = !m_error & (m_arb ? !s1_to_m_dempty  :   !s0_to_m_dempty);
assign m_wb_dat_i  = m_arb ? s1_to_m_data_o   :   s0_to_m_data_o;
assign m_wb_stall_i = m_addr_s0_hit & m_to_s0_hfull | m_addr_s1_hit & m_to_s1_hfull | m_dir_fst[WB_M_BSCALE -1];

assign m_wb_err_i  = m_error;

assign s1_to_m_drden = m_arb & m_wb_ack_i & !m_error;
assign s0_to_m_drden = !m_arb & m_wb_ack_i & !m_error;

//from master to slave0
wire m_to_s0_hwren = m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i & m_addr_s0_hit;
wire m_to_s0_dwren = m_to_s0_hwren & m_wb_we_o;

assign m_to_s0_header_i    = {m_wb_addr_o, m_wb_sel_o, m_wb_we_o, time_tag};
assign m_to_s0_data_i      = m_wb_dat_o;

wb_com_fifo     #(WB_HDR_WIDTH, WB_FIFO_ASIZE)
s0_header_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m_to_s0_hwren),
.wr_data        (m_to_s0_header_i),

.rd_en          (m_to_s0_hrden),
.rd_data        (m_to_s0_header_o),

.full           (m_to_s0_hfull),
.empty          (m_to_s0_hempty)
);

wb_com_fifo     #(WB_DATA_WIDTH, WB_FIFO_ASIZE)
s0_data_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m_to_s0_dwren),
.wr_data        (m_to_s0_data_i),

.rd_en          (m_to_s0_drden),
.rd_data        (m_to_s0_data_o),

.full           (),
.empty          ()
);


//from master to slave1
wire m_to_s1_hwren = m_wb_cyc_o & m_wb_stb_o & !m_wb_stall_i & m_addr_s1_hit;
wire m_to_s1_dwren = m_to_s1_hwren & m_wb_we_o;

assign m_to_s1_header_i     = {m_wb_addr_o, m_wb_sel_o, m_wb_we_o, time_tag};
assign m_to_s1_data_i       = m_wb_dat_o;

wb_com_fifo     #(WB_HDR_WIDTH, WB_FIFO_ASIZE)
s1_header_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m_to_s1_hwren),
.wr_data        (m_to_s1_header_i),

.rd_en          (m_to_s1_hrden),
.rd_data        (m_to_s1_header_o),

.full           (m_to_s1_hfull),
.empty          (m_to_s1_hempty)
);

wb_com_fifo     #(WB_DATA_WIDTH, WB_FIFO_ASIZE)
s1_data_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m_to_s1_dwren),
.wr_data        (m_to_s1_data_i),

.rd_en          (m_to_s1_drden),
.rd_data        (m_to_s1_data_o),

.full           (),
.empty          ()
);


endmodule
`endif
