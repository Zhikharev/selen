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
                "ADD", OP_R,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_reg<sword_t>(i.rs1()) + core.get_reg<sword_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b010),
                "SLT", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<sword_t>(i.rs1()) < core.get_reg<sword_t>(i.rs2())) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b011),
                "SLTU", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<word_t>(i.rs1()) < core.get_reg<word_t>(i.rs2())) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b111),
                "AND", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) & core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b110),
                "OR", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) | core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b100),
                "XOR", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) ^ core.get_reg<word_t>(i.rs2());
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b001),
                "SLL", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) << (core.get_reg<word_t>(i.rs2()) & 0x1f); // lower five bits
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b101),
                "SRL", OP_R,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) >> (core.get_reg<word_t>(i.rs2()) & 0x1f);
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func7(0b0100000) | func3(0b101),
                "SRA", OP_R,
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
                "SUB", OP_R,
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

//            {(32u<<3)|0b010,
//             {
//                 "AM",
//                 []OPERATION
//                 {
//                     st.reg[d].s = (st.reg[s1].s + st.reg[s2].s) / 2;
//                 }
//             }
//            }
}; //R

} // namespace isa
} // namespace selen

#endif // ISA_R_H
