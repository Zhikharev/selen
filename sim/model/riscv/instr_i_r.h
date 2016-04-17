#ifndef ISA_I_R_H
#define ISA_I_R_H

// I_R-type instruction implementation

#include "decode.h"

namespace selen
{
namespace isa
{

struct I_R
{
    static const word_t opcode = OP_I_R;

    //0-6 -opcode, func3 12-14, func7 25 - 31
    static const word_t mask3 = {0x7000};
    static const word_t mask7_3 = {0xfe007000};

#define func3(x) ((x) << 12)
#define func7(x) ((x) << 25)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                mask3, 0,
                "addi", I_R::print,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_reg<sword_t>(i.rs1()) + i.immI();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask3, func3(0b010),
                "slti", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<sword_t>(i.rs1()) < i.immI()) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask3, func3(0b011),
                "sltiu", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = (core.get_reg<word_t>(i.rs1()) < static_cast<word_t>(i.immI())) ? 1 : 0;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask3, func3(0b111),
                "andi", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) & i.immI();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask3, func3(0b110),
                "ori", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) | i.immI();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask3, func3(0b100),
                "xori", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) ^ i.immI();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask7_3, func3(0b001),
                "slli", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) << (i.immI() & 0x1f); // lower five bits
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask7_3, func3(0b101),
                "srli", I_R::print,
                [] ISA_OPERATION
                {
                    word_t value = core.get_reg<word_t>(i.rs1()) >> (i.immI() & 0x1f);
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask7_3, func7(0b0100000) | func3(0b101),
                "srai", I_R::print,
                [] ISA_OPERATION
                {
                    //FIXME: right ariphmetic shift is not defined by C++ standard.
                    sword_t value = core.get_reg<sword_t>(i.rs1()) >> (i.immI() & 0x1f);
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
            << std::dec << i.immI()
            << "(" << XPR::id2name(i.rs1()) << ")";
    }

}; //I_R

} // namespace isa
} // namespace selen
#endif // ISA_I_R_H
