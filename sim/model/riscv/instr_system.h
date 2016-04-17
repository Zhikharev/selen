#ifndef INSTR_SYSTEM_H
#define INSTR_SYSTEM_H

// RISC V system instructions

#include "decode.h"

namespace selen
{

namespace isa
{

struct SYSTEM
{
    static const word_t opcode = OP_SYSTEM;

    //0-6 -opcode, func3 12-14, I imm 20 - 31
    static const word_t mask = {0xfff07000};

#define func3(x) ((x) << 12)
#define func12(x) ((x) << 20)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product; //=
//        {
//            {
//                mask, 0,
//                "scall", SYSTEM::print,
//                [] ISA_OPERATION
//                {
//                    sword_t value = core.get_reg<sword_t>(i.rs1()) + i.immI();
//                    core.set_reg(i.rd(), value);
//                    core.increment_pc();
//                }
//            },
//            {
//                mask, func12(1),
//                "sbreak", SYSTEM::print,
//                [] ISA_OPERATION
//                {
//                    word_t value = (core.get_reg<sword_t>(i.rs1()) < i.immI()) ? 1 : 0;
//                    core.set_reg(i.rd(), value);
//                    core.increment_pc();
//                }
//            },
//            {
//                mask, func3(0b010),
//                "rdcycle", SYSTEM::print,
//                [] ISA_OPERATION
//                {
//                    word_t value = (core.get_reg<word_t>(i.rs1()) < static_cast<word_t>(i.immI())) ? 1 : 0;
//                    core.set_reg(i.rd(), value);
//                    core.increment_pc();
//                }
//            },
//            {
//                mask, func3(0b111),
//                "rdtime", SYSTEM::print,
//                [] ISA_OPERATION
//                {
//                    word_t value = core.get_reg<word_t>(i.rs1()) & i.immI();
//                    core.set_reg(i.rd(), value);
//                    core.increment_pc();
//                }
//            },
//            {
//                mask, func3(0b110),
//                "rdinstret", SYSTEM::print,
//                [] ISA_OPERATION
//                {
//                    word_t value = core.get_reg<word_t>(i.rs1()) | i.immI();
//                    core.set_reg(i.rd(), value);
//                    core.increment_pc();
//                }
//            }
//        };

        return product;
    }

    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << std::setw(RN_WIDHT) << XPR::id2name(i.rd()) << ","
            << std::hex << std::showbase
            << i.immUJ();
    }
}; //I_R

} // namespace isa
} // namespace selen

#endif // INSTR_SYSTEM_H
