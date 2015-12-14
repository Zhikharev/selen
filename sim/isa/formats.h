#ifndef ISA_FORMATS_H
#define ISA_FORMATS_H

//RISC-V instruction formats: R, I, S, U;

#include <cassert>

#include "definitions.h"

namespace selen
{
namespace isa
{

//opcode field type
typedef   uint8_t opcode_t;
constexpr size_t  OPCODE_BIT_SIZE = 7;

enum : opcode_t
{

    OP_R     = 0b0110011,
    OP_I_R   = 0b0010011,
    OP_LUI   = 0b0110111,
    OP_AUIPC = 0b0010111,
    OP_SB    = 0b1100011,
    OP_JAL   = 0b1101111,
    OP_JALR  = 0b1100111,
    OP_LOAD  = 0b0000011,
    OP_STORE = 0b0100011,
};

//instruction selector field type
typedef uint16_t funct_t;

#pragma pack(push, 1)
struct formatR
{
    opcode_t opcode  : OPCODE_BIT_SIZE;
    reg_id_t  rd     : 5;
    funct_t  funct3  : 3;
    reg_id_t  rs1    : 5;
    reg_id_t  rs2    : 5;
    funct_t  funct7  : 7;
};

struct formatI
{
    opcode_t opcode  : OPCODE_BIT_SIZE;
    reg_id_t  rd     : 5;
    funct_t  funct3  : 3;
    reg_id_t  rs1    : 5;
    word_t  imm11_0  : 11;

    word_t get_immediate() const
    {
        sword_t product = imm11_0;

        //signed extension
        return ((product << 21) >> 21);
    }
};

struct formatS
{
    opcode_t opcode    : OPCODE_BIT_SIZE;
    word_t     imm0    : 1;
    word_t     imm4_1  : 4;
    funct_t    funct3   : 3;
    reg_id_t    rs1    : 5;
    reg_id_t    rs2    : 5;
    word_t     imm10_5 : 6;
    word_t     imm11   : 1;

    struct immlayout_t
    {
        word_t p0      : 1;
        word_t p4_1    : 4;
        word_t p10_5   : 6;
        word_t p11     : 1;
        word_t padding : 20;
    } ;

    static_assert(sizeof(immlayout_t) == sizeof(word_t), "Bad struct size fit");

    addr_t get_S_immediate() const
    {
        union
        {
            sword_t s;
            immlayout_t l;
        } c = {0};

        c.l.p0 = imm0;
        c.l.p4_1 = imm4_1;
        c.l.p10_5 = imm10_5;
        c.l.p11 = imm11;

        //signed extension
        return ((c.s << 21) >> 21);
    }

    addr_t get_B_immediate() const
    {
        union
        {
            sword_t s;
            immlayout_t l;
        } c = {0};

        c.l.p0 = 0;
        c.l.p4_1 = imm4_1;
        c.l.p10_5 = imm10_5;
        c.l.p11 = imm0;
        c.l.padding = imm11;

        //signed extension
        return ((c.s << 20) >> 20);
    }
};

struct formatU
{
    opcode_t opcode   : OPCODE_BIT_SIZE;
    reg_id_t  rd      : 5;
    word_t  imm31_12  : 20;


    word_t get_U_immediate() const
    {
        return (imm31_12 << 12);
    }

    word_t get_J_immediate() const
    {
        sword_t result = 0;

        //1bit == 0

        //10 -1 bit
        result |= (bit_seq(imm31_12, 9, 19) << 1);

        //11 bit
        result |= (bit_seq(imm31_12, 8, 9) << 11);

        //12-19
        result |= (bit_seq(imm31_12, 0, 8) << 12);

        //last 20, sign
        result |= (bit_seq(imm31_12, 20, 21) << 20);
        //signed extension
        return ((result << 12) >> 12);
    }
};
#pragma pack(pop)

} //namesapce isa
} //namesapce selen

#endif // ISA_FORMATS_H
