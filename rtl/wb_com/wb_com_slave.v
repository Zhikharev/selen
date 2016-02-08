module  wb_com_slave 
(
clk,
rst,
                     
//WB INTARFACE                          
s_wb_addr_o,
s_wb_dat_o,
s_wb_sel_o,
s_wb_cyc_o,
s_wb_stb_o,
s_wb_we_o,
                    
s_wb_dat_i,
s_wb_stall_i,
s_wb_ack_i,
                     
//DATA from M0                          
m0_to_s_header_o,
m0_to_s_hrden,
m0_to_s_data_o,
m0_to_s_drden,
m0_to_s_hempty,
                     
//DATA to M0                            
s_to_m0_data_o,
s_to_m0_drden,
s_to_m0_dempty,
                     
//DATA from M1                          
m1_to_s_header_o,
m1_to_s_hrden,
m1_to_s_data_o,
m1_to_s_drden,
m1_to_s_hempty,
                     
//DATA to M1                            
s_to_m1_data_o,
s_to_m1_drden,
s_to_m1_dempty
);

parameter   WB_ADDR_WIDTH       =   32;
parameter   WB_DATA_WIDTH       =   32;
parameter   WB_FIFO_ASIZE       =   2;

parameter   WB_TIME_TAG         =   WB_FIFO_ASIZE + 2;
parameter   WB_SEL_WIDTH        =   WB_DATA_WIDTH/8;
parameter   WB_HDR_WIDTH        =   WB_ADDR_WIDTH + WB_TIME_TAG + WB_SEL_WIDTH +1;
parameter   WB_M_BSCALE         =   (1 << (WB_TIME_TAG-1));
input                               clk;
input                               rst;
//WB INTARFACE                          
output  [WB_ADDR_WIDTH - 1:0]       s_wb_addr_o;
output  [WB_DATA_WIDTH - 1:0]       s_wb_dat_o;
output  [WB_SEL_WIDTH - 1:0]        s_wb_sel_o;
output                              s_wb_cyc_o;
output                              s_wb_stb_o;
output                              s_wb_we_o;

input   [WB_DATA_WIDTH - 1:0]       s_wb_dat_i;
input                               s_wb_stall_i;
input                               s_wb_ack_i;

//DATA from M0                          
input  [WB_HDR_WIDTH - 1:0]         m0_to_s_header_o;
output                              m0_to_s_hrden;
input  [WB_DATA_WIDTH - 1:0]        m0_to_s_data_o;
output                              m0_to_s_drden;
input                               m0_to_s_hempty;

//DATA to M0                            
output   [WB_DATA_WIDTH - 1:0]      s_to_m0_data_o;
input                               s_to_m0_drden;
output                              s_to_m0_dempty;

//DATA from M1                          
input  [WB_HDR_WIDTH - 1:0]         m1_to_s_header_o;
output                              m1_to_s_hrden;
input  [WB_DATA_WIDTH - 1:0]        m1_to_s_data_o;
output                              m1_to_s_drden;
input                               m1_to_s_hempty;

//DATA to M1                            
output   [WB_DATA_WIDTH - 1:0]      s_to_m1_data_o;
input                               s_to_m1_drden;
output                              s_to_m1_dempty;

reg [WB_M_BSCALE-1:0]               s_dir_sel, s_dir_fst;
wire                                m1_dir;
//common signals
wire [WB_TIME_TAG-1:0] m0_time_tag    = m0_to_s_header_o[WB_TIME_TAG-1:0];
wire [WB_TIME_TAG-1:0] m1_time_tag    = m1_to_s_header_o[WB_TIME_TAG-1:0];

assign m1_dir   = m0_to_s_hempty | !m1_to_s_hempty & ((m1_time_tag[WB_TIME_TAG-1] ^ m0_time_tag[WB_TIME_TAG-1]) ? m1_time_tag[WB_TIME_TAG-2:0] > m0_time_tag[WB_TIME_TAG-2:0] : 
                                                                                m1_time_tag[WB_TIME_TAG-2:0] < m0_time_tag[WB_TIME_TAG-2:0]);

always @(posedge clk)
if (rst)                                            s_dir_sel <= {WB_M_BSCALE{1'b0}};
else if (s_wb_cyc_o & s_wb_stb_o & !s_wb_stall_i)   s_dir_sel <= {s_dir_sel[6:0], m1_dir};

always @(posedge clk)
if (rst)                                                            s_dir_fst <= {WB_M_BSCALE{1'b0}};
else if (s_wb_ack_i & !(s_wb_cyc_o & s_wb_stb_o & !s_wb_stall_i))   s_dir_fst <= {1'b0, s_dir_fst[WB_M_BSCALE-1:1]};
else if (s_wb_cyc_o & s_wb_stb_o & !s_wb_stall_i & !s_wb_ack_i)     s_dir_fst <= {s_dir_fst[WB_M_BSCALE-2:0], !(|s_dir_fst)};

assign s_wb_cyc_o = !m0_to_s_hempty | !m1_to_s_hempty | |s_dir_fst;
assign s_wb_stb_o = !m0_to_s_hempty | !m1_to_s_hempty;

assign s_wb_addr_o  = m1_dir ? m1_to_s_header_o[WB_HDR_WIDTH-1:WB_TIME_TAG + WB_SEL_WIDTH+1]    : m0_to_s_header_o[WB_HDR_WIDTH-1:WB_TIME_TAG + WB_SEL_WIDTH+1];
assign s_wb_sel_o   = m1_dir ? m1_to_s_header_o[WB_TIME_TAG + WB_SEL_WIDTH:WB_TIME_TAG+1]       : m0_to_s_header_o[WB_TIME_TAG + WB_SEL_WIDTH:WB_TIME_TAG+1];
assign s_wb_we_o    = m1_dir ? m1_to_s_header_o[WB_TIME_TAG]                                    : m0_to_s_header_o[WB_TIME_TAG];

assign s_wb_dat_o   = m1_dir ? m1_to_s_data_o : m0_to_s_data_o;

assign m0_to_s_hrden    = !m1_dir & s_wb_stb_o;
assign m1_to_s_hrden    = m1_dir & s_wb_stb_o;

//to m0
assign m0_fifo_wren = (|s_dir_fst & !(|(s_dir_fst & s_dir_sel)) | !(|s_dir_fst) & !m1_dir & !m0_to_s_hempty) & s_wb_ack_i;
wb_com_fifo     #(WB_DATA_WIDTH, WB_FIFO_ASIZE+1)
m0_data_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m0_fifo_wren),
.wr_data        (s_wb_dat_i),

.rd_en          (s_to_m0_drden),
.rd_data        (s_to_m0_data_o),

.full           (),
.empty          (s_to_m0_dempty)
);

//to m1
assign m1_fifo_wren = (|s_dir_fst & (|(s_dir_fst & s_dir_sel)) | !(|s_dir_fst) & m1_dir & !m1_to_s_hempty) & s_wb_ack_i;
wb_com_fifo     #(WB_DATA_WIDTH, WB_FIFO_ASIZE+1)
m1_data_fifo
(
.clk            (clk),
.rst            (rst),

.wr_en          (m1_fifo_wren),
.wr_data        (s_wb_dat_i),

.rd_en          (s_to_m1_drden),
.rd_data        (s_to_m1_data_o),

.full           (),
.empty          (s_to_m1_dempty)
);

endmodule
