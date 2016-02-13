`define R_TYPE  7'b0110011
`define I_TYPE  7'b0010011

`define LUI     7'b0110111
`define AUIPC   7'b0010111

`define SB_TYPE 7'b1100011
`define UJ_TYPE 7'b1101111
`define JALR    7'b1100111
`define LOAD    7'b0000011
`define STORE   7'b0100011


typedef enum int{
    ADD,
    SLT,
    SLTU,
    AND,
    OR,
    XOR,
    SLL,
    SRL,
    SUB,
    SRA,
    AM,
    ADDI,
    SLTI,
    SLTIU,
    ANDI,
    ORI,
    XORI,
    SLLI,
    SRLI,
    SRAI,
    LUI,
    AUIPC,
    JALR,
    LW,
    LH,
    LHU,
    LB,
    LBU,
    BEQ,
    BNE,
    BLT,
    BLTU,
    BGE,
    BGEU,
    SW,
    SH,
    SB,
    JAL
} opcode_t;

