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
//                          WB_COM_DWIDTH - width of dat_o, dat_i
//                          WB_COM_F_ASIZE - size of address bits in internal
//                          fifo. Depends on size of unanswered transaction of
//                          each slave that will be stored in fifo before 
//                          generation of stall_i signal on master interface.
//                          WB_COM_S0_ABASE - base address for transactions
//                          for slave 0 (must be same width as addr_o)
//                          WB_COM_S0_AMASK - adress mask for slave 0 
//                          WB_COM_S1_ABASE - base address for transactions
//                          for slave 1 (must be same width as addr_o)
//                          WB_COM_S1_AMASK - adress mask for slave 1 
// ----------------------------------------------------------------------------
`ifndef INC_WB_COM_DEFINES
`define INC_WB_COM_DEFINES


`define WB_COM_AWIDTH            32
`define WB_COM_DWIDTH            32
`define WB_COM_F_ASIZE           2
`define WB_COM_S0_ABASE          32'h00000000
`define WB_COM_S0_AMASK          2'b11
`define WB_COM_S1_ABASE          32'h00000004
`define WB_COM_S1_AMASK          2'b11
