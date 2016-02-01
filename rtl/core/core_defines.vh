`define PS_START 32'b0
/// mux bus bellow 
`define R_MUX 6'b0xx010
`define I_R_MUX 6'b0xx010
`define LUI_MUX 6'bxxxxxx
`define AUIPC_MUX 6'b0xx010
`define SB_MUX	6'bx0x000
`define UJ_MUX 6'bx10xx1
`define LD_MUX 6'b111xx0
`define ST_MUX 6'bx11xx0
`define JALR_MUX 6'bx11xx1
// forwarding bus bellow 
`define M2E_SRC1_BP	5'bxxxx0
`define W2E_SRC1_BP	5'bxxx01
`define M2E_SRC2_BP 5'bxx0xx
`define W2E_SRC2_BP 5'bx01xx
`define W2M_BP 5'b1xxxx
`define START_BP 5'b01111
