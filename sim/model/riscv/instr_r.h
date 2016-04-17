#ifndef ISA_R_H
#define ISA_R_H

//R-type instructions, Integer Register-Register Operations

#include "decode.h"

namespace selen
{

namespace isa
{

struct R
{
    static const word_t opcode = OP_R;

    //0-6 -opcode, func3 12-14, func7 25 - 31
    static const word_t mask = {0xfe007000};

#define func3(x) ((x) << 12)
#define func7(x) ((x) << 25)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                mask, 0,
                "add", R::print,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_reg<sword_t>(i.rs1()) + core.get_reg<sword_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b010),
                "slt", R::print,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<sword_t>(i.rs1()) < core.get_reg<sword_t>(i.rs2())) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b011),
                "sltu", R::print,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<word_t>(i.rs1()) < core.get_reg<word_t>(i.rs2())) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b111),
                "and", R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) & core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b110),
                "or", R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) | core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b100),
                "xor", R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) ^ core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b001),
                "sll", R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) << (core.get_reg<word_t>(i.rs2()) & 0x1f); // lower five bits
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b101),
                "srl", R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) >> (core.get_reg<word_t>(i.rs2()) & 0x1f);
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func7(0b0100000) | func3(0b101),
                "sra", R::print,
                [] ISA_OPERATION
                {
                    //FIXME: right ariphmetic shift is not defined by C++ standard.
                    sword_t value = core.get_reg<sword_t>(i.rs1()) >> (core.get_reg<word_t>(i.rs2()) & 0x1f);
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func7(0b0100000),
                "sub", R::print,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_reg<sword_t>(i.rs1()) - core.get_reg<sword_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            }
        };

        return product;
    }


    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << std::setw(RN_WIDHT) << XPR::id2name(i.rd()) << ","
            << std::setw(RN_WIDHT) << XPR::id2name(i.rs1()) << ","
            << XPR::id2name(i.rs2());
    }
}; //R

} // namespace isa
} // namespace selen

#endif // ISA_R_H
