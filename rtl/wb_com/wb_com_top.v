// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            : wb_com_top.v
// PROJECT              : Selen
// AUTHOR               : Pavel Petrakov
// AUTHOR'S EMAIL       : 
// ----------------------------------------------------------------------------
// DESCRIPTION          : top module of wishbone commutator with 2 masters and
//                          2 slaves
// ----------------------------------------------------------------------------
//`include    "wb_com_defines.v"

`ifndef INC_WB_COM_TOP
`define INC_WB_COM_TOP

module wb_com_top
(
clk_i,
rst_i,

//Master 0 wb interface
m0_wb_addr_o,
m0_wb_dat_o,
m0_wb_sel_o,
m0_wb_cyc_o,
m0_wb_stb_o,
m0_wb_we_o,

m0_wb_dat_i,
m0_wb_stall_i,
m0_wb_ack_i,
m0_wb_err_i,

//Master 1 wb interface
m1_wb_addr_o,
m1_wb_dat_o,
m1_wb_sel_o,
m1_wb_cyc_o,
m1_wb_stb_o,
m1_wb_we_o,

m1_wb_dat_i,
m1_wb_stall_i,
m1_wb_ack_i,
m1_wb_err_i,

//Slave 0 wb interface
s0_wb_addr_o,
s0_wb_dat_o,
s0_wb_sel_o,
s0_wb_cyc_o,
s0_wb_stb_o,
s0_wb_we_o,

s0_wb_dat_i,
s0_wb_stall_i,
s0_wb_ack_i,

//Slave 1 wb interface
s1_wb_addr_o,
s1_wb_dat_o,
s1_wb_sel_o,
s1_wb_cyc_o,
s1_wb_stb_o,
s1_wb_we_o,

s1_wb_dat_i,
s1_wb_stall_i,
s1_wb_ack_i
);
parameter   WB_ADDR_WIDTH       =   `WB_COM_AWIDTH;
parameter   WB_DATA_WIDTH       =   `WB_COM_DWIDTH;
parameter   WB_FIFO_ASIZE       =   `WB_COM_F_ASIZE;
parameter   S0_ADDR_BASE        =   `WB_COM_S0_ABASE;
parameter   S0_ADDR_MASK        =   `WB_COM_S0_AMASK;
parameter   S1_ADDR_BASE        =   `WB_COM_S0_ABASE;
parameter   S1_ADDR_MASK        =   `WB_COM_S0_AMASK;


parameter   WB_TIME_TAG         =   WB_FIFO_ASIZE + 2;
parameter   WB_SEL_WIDTH        =   WB_DATA_WIDTH/8;
parameter   WB_HDR_WIDTH        =   WB_ADDR_WIDTH + WB_TIME_TAG + WB_SEL_WIDTH +1;


input                               clk_i;
input                               rst_i;

//wb master 0
input   [WB_ADDR_WIDTH - 1:0]       m0_wb_addr_o;
input   [WB_DATA_WIDTH - 1:0]       m0_wb_dat_o;
input   [WB_SEL_WIDTH - 1:0]        m0_wb_sel_o;
input                               m0_wb_cyc_o;
input                               m0_wb_stb_o;
input                               m0_wb_we_o;

output  [WB_DATA_WIDTH - 1:0]       m0_wb_dat_i;
output                              m0_wb_stall_i;
output                              m0_wb_ack_i;
output                              m0_wb_err_i;

//wb master 1
input   [WB_ADDR_WIDTH - 1:0]       m1_wb_addr_o;
input   [WB_DATA_WIDTH - 1:0]       m1_wb_dat_o;
input   [WB_SEL_WIDTH - 1:0]        m1_wb_sel_o;
input                               m1_wb_cyc_o;
input                               m1_wb_stb_o;
input                               m1_wb_we_o;

output  [WB_DATA_WIDTH - 1:0]       m1_wb_dat_i;
output                              m1_wb_stall_i;
output                              m1_wb_ack_i;
output                              m1_wb_err_i;

//wb slave 0
output  [WB_ADDR_WIDTH - 1:0]       s0_wb_addr_o;
output  [WB_DATA_WIDTH - 1:0]       s0_wb_dat_o;
output  [WB_SEL_WIDTH - 1:0]        s0_wb_sel_o;
output                              s0_wb_cyc_o;
output                              s0_wb_stb_o;
output                              s0_wb_we_o;

input   [WB_DATA_WIDTH - 1:0]       s0_wb_dat_i;
input                               s0_wb_stall_i;
input                               s0_wb_ack_i;

//wb slave 1
output  [WB_ADDR_WIDTH - 1:0]       s1_wb_addr_o;
output  [WB_DATA_WIDTH - 1:0]       s1_wb_dat_o;
output  [WB_SEL_WIDTH - 1:0]        s1_wb_sel_o;
output                              s1_wb_cyc_o;
output                              s1_wb_stb_o;
output                              s1_wb_we_o;

input   [WB_DATA_WIDTH - 1:0]       s1_wb_dat_i;
input                               s1_wb_stall_i;
input                               s1_wb_ack_i;

wire    [WB_HDR_WIDTH - 1:0]       m0_to_s0_header_o, m0_to_s1_header_o, m1_to_s0_header_o, m1_to_s1_header_o;
wire    [WB_DATA_WIDTH - 1:0]        m0_to_s0_data_o, m0_to_s1_data_o, m1_to_s0_data_o, m1_to_s1_data_o,
                                    s0_to_m0_data_o, s0_to_m1_data_o, s1_to_m0_data_o, s1_to_m1_data_o;

//direction to slave fifo's
reg [WB_TIME_TAG -1:0]       time_tag;
always @(posedge clk_i)
if (rst_i)        time_tag <= {WB_TIME_TAG{1'd0}};
else if (m0_wb_cyc_o & m0_wb_stb_o & !m0_wb_stall_i | m1_wb_cyc_o & m1_wb_stb_o & !m1_wb_stall_i) time_tag <= time_tag + 1'b1;

wb_com_master       
#(WB_ADDR_WIDTH, WB_DATA_WIDTH, WB_TIME_TAG, S0_ADDR_BASE, S0_ADDR_MASK, S1_ADDR_BASE, S1_ADDR_MASK)
m0_part
(
.clk                (clk_i              ),
.rst                (rst_i              ),

//WB INTARFACE                          
.m_wb_addr_o        (m0_wb_addr_o       ),
.m_wb_dat_o         (m0_wb_dat_o        ),
.m_wb_sel_o         (m0_wb_sel_o        ),
.m_wb_cyc_o         (m0_wb_cyc_o        ),
.m_wb_stb_o         (m0_wb_stb_o        ),
.m_wb_we_o          (m0_wb_we_o         ),
                                        
.m_wb_dat_i         (m0_wb_dat_i        ),
.m_wb_stall_i       (m0_wb_stall_i      ),
.m_wb_ack_i         (m0_wb_ack_i        ),
.m_wb_err_i         (m0_wb_err_i        ),
                                        
.time_tag           (time_tag           ),
 
//DATA from M0                          
.m_to_s0_header_o   (m0_to_s0_header_o  ),
.m_to_s0_hrden      (m0_to_s0_hrden     ),
.m_to_s0_data_o     (m0_to_s0_data_o    ),
.m_to_s0_drden      (m0_to_s0_drden     ),
.m_to_s0_hempty     (m0_to_s0_hempty    ),
                                        
.m_to_s1_header_o   (m0_to_s1_header_o  ),
.m_to_s1_hrden      (m0_to_s1_hrden     ),
.m_to_s1_data_o     (m0_to_s1_data_o    ),
.m_to_s1_drden      (m0_to_s1_drden     ),
.m_to_s1_hempty     (m0_to_s1_hempty    ),

//DATA to M0                            
.s0_to_m_data_o     (s0_to_m0_data_o    ),
.s0_to_m_drden      (s0_to_m0_drden     ),
.s0_to_m_dempty     (s0_to_m0_dempty    ),
                                        
.s1_to_m_data_o     (s1_to_m0_data_o    ),
.s1_to_m_drden      (s1_to_m0_drden     ),
.s1_to_m_dempty     (s1_to_m0_dempty    )

);

wb_com_master       
#(WB_ADDR_WIDTH, WB_DATA_WIDTH, WB_TIME_TAG, S0_ADDR_BASE, S0_ADDR_MASK, S1_ADDR_BASE, S1_ADDR_MASK)
m1_part
(
.clk                (clk_i              ),
.rst                (rst_i              ),

//WB INTARFACE                          
.m_wb_addr_o        (m1_wb_addr_o       ),
.m_wb_dat_o         (m1_wb_dat_o        ),
.m_wb_sel_o         (m1_wb_sel_o        ),
.m_wb_cyc_o         (m1_wb_cyc_o        ),
.m_wb_stb_o         (m1_wb_stb_o        ),
.m_wb_we_o          (m1_wb_we_o         ),
                                        
.m_wb_dat_i         (m1_wb_dat_i        ),
.m_wb_stall_i       (m1_wb_stall_i      ),
.m_wb_ack_i         (m1_wb_ack_i        ),
.m_wb_err_i         (m1_wb_err_i        ),
                                        
.time_tag           (time_tag           ),

//DATA from M1                          
.m_to_s0_header_o   (m1_to_s0_header_o  ),
.m_to_s0_hrden      (m1_to_s0_hrden     ),
.m_to_s0_data_o     (m1_to_s0_data_o    ),
.m_to_s0_drden      (m1_to_s0_drden     ),
.m_to_s0_hempty     (m1_to_s0_hempty    ),
                                        
.m_to_s1_header_o   (m1_to_s1_header_o  ),
.m_to_s1_hrden      (m1_to_s1_hrden     ),
.m_to_s1_data_o     (m1_to_s1_data_o    ),
.m_to_s1_drden      (m1_to_s1_drden     ),
.m_to_s1_hempty     (m1_to_s1_hempty    ),

//DATA to M1                            
.s0_to_m_data_o     (s0_to_m1_data_o    ),
.s0_to_m_drden      (s0_to_m1_drden     ),
.s0_to_m_dempty     (s0_to_m1_dempty    ),
                                        
.s1_to_m_data_o     (s1_to_m1_data_o    ),
.s1_to_m_drden      (s1_to_m1_drden     ),
.s1_to_m_dempty     (s1_to_m1_dempty    )

);

wb_com_slave        
#(WB_ADDR_WIDTH, WB_DATA_WIDTH, WB_FIFO_ASIZE)
s0_part
(
.clk                (clk_i              ),
.rst                (rst_i              ),
                     
//WB INTARFACE                          
.s_wb_addr_o        (s0_wb_addr_o       ),
.s_wb_dat_o         (s0_wb_dat_o        ),
.s_wb_sel_o         (s0_wb_sel_o        ),
.s_wb_cyc_o         (s0_wb_cyc_o        ),
.s_wb_stb_o         (s0_wb_stb_o        ),
.s_wb_we_o          (s0_wb_we_o         ),
                     
.s_wb_dat_i         (s0_wb_dat_i        ),
.s_wb_stall_i       (s0_wb_stall_i      ),
.s_wb_ack_i         (s0_wb_ack_i        ),
                     
//DATA from M0                          
.m0_to_s_header_o   (m0_to_s0_header_o  ),
.m0_to_s_hrden      (m0_to_s0_hrden     ),
.m0_to_s_data_o     (m0_to_s0_data_o    ),
.m0_to_s_drden      (m0_to_s0_drden     ),
.m0_to_s_hempty     (m0_to_s0_hempty    ),
                     
//DATA to M0                            
.s_to_m0_data_o     (s0_to_m0_data_o    ),
.s_to_m0_drden      (s0_to_m0_drden     ),
.s_to_m0_dempty     (s0_to_m0_dempty    ),
                     
//DATA from M1                          
.m1_to_s_header_o   (m1_to_s0_header_o  ),
.m1_to_s_hrden      (m1_to_s0_hrden     ),
.m1_to_s_data_o     (m1_to_s0_data_o    ),
.m1_to_s_drden      (m1_to_s0_drden     ),
.m1_to_s_hempty     (m1_to_s0_hempty    ),
                     
//DATA to M1                            
.s_to_m1_data_o     (s0_to_m1_data_o    ),
.s_to_m1_drden      (s0_to_m1_drden     ),
.s_to_m1_dempty     (s0_to_m1_dempty    )
);

wb_com_slave        
#(WB_ADDR_WIDTH, WB_DATA_WIDTH, WB_FIFO_ASIZE)
s1_part
(
.clk                (clk_i              ),
.rst                (rst_i              ),
                     
//WB INTARFACE                          
.s_wb_addr_o        (s1_wb_addr_o       ),
.s_wb_dat_o         (s1_wb_dat_o        ),
.s_wb_sel_o         (s1_wb_sel_o        ),
.s_wb_cyc_o         (s1_wb_cyc_o        ),
.s_wb_stb_o         (s1_wb_stb_o        ),
.s_wb_we_o          (s1_wb_we_o         ),
                     
.s_wb_dat_i         (s1_wb_dat_i        ),
.s_wb_stall_i       (s1_wb_stall_i      ),
.s_wb_ack_i         (s1_wb_ack_i        ),
                     
//DATA from M0                          
.m0_to_s_header_o   (m0_to_s1_header_o  ),
.m0_to_s_hrden      (m0_to_s1_hrden     ),
.m0_to_s_data_o     (m0_to_s1_data_o    ),
.m0_to_s_drden      (m0_to_s1_drden     ),
.m0_to_s_hempty     (m0_to_s1_hempty    ),
                     
//DATA to M0                            
.s_to_m0_data_o     (s1_to_m0_data_o    ),
.s_to_m0_drden      (s1_to_m0_drden     ),
.s_to_m0_dempty     (s1_to_m0_dempty    ),
                     
//DATA from M1                          
.m1_to_s_header_o   (m1_to_s1_header_o  ),
.m1_to_s_hrden      (m1_to_s1_hrden     ),
.m1_to_s_data_o     (m1_to_s1_data_o    ),
.m1_to_s_drden      (m1_to_s1_drden     ),
.m1_to_s_hempty     (m1_to_s1_hempty    ),
                     
//DATA to M1                            
.s_to_m1_data_o     (s1_to_m1_data_o    ),
.s_to_m1_drden      (s1_to_m1_drden     ),
.s_to_m1_dempty     (s1_to_m1_dempty    )
);

endmodule
`endif
