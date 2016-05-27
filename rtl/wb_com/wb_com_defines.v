// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME            : wb_com_defines.v
// PROJECT              : Selen
// AUTHOR               : Pavel Petrakov
// AUTHOR'S EMAIL       :
// ----------------------------------------------------------------------------
// DESCRIPTION          :   defines that used in wishbone commutator
//                          WB_COM_AWIDTH - width of addr_o, addr_i
//
//                          WB_COM_DWIDTH - width of dat_o, dat_i
//
//                          WB_COM_F_ASIZE - size of address bits in internal
//                          fifo. Depends on size of unanswered transaction of
//                          each slave that will be stored in fifo before
//                          generation of stall_i signal on master interface.
//
//                          WB_COM_S0_AHI &  
//                          WB_COM_S0_ALO - Higher  and lower addresses of
//                          address space for slave 0 (WB_COM_S0_AHI MUST BE
//                          MORE THAN WB_COM_S0_ALO) Transanction with address
//                          that >= WB_COM_S0_ALO and <= WB_COM_S0_AHI will be
//                          directed to slave 0
//
//                          WB_COM_S1_AHI & 
//                          WB_COM_S1_ALO - same as for slave 0
// ----------------------------------------------------------------------------
`ifndef INC_WB_COM_DEFINES
`define INC_WB_COM_DEFINES


`define WB_COM_AWIDTH            32
`define WB_COM_DWIDTH            32
`define WB_COM_F_ASIZE           2
`define WB_COM_S0_HI          16'h0000_2fff
`define WB_COM_S0_LO          32'h0000_0000 
`define WB_COM_S1_HI          32'h0004_ffff
`define WB_COM_S1_LO          32'h0001_0000
`endif
