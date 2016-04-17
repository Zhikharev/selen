#ifndef ISA_SB_H
#define ISA_SB_H

#include "decode.h"

/*
 * SB-type instruction
 */

namespace selen
{

namespace isa
{

struct SB
{
    static const word_t opcode = OP_SB;

    //0-6 -opcode, func3 12-14
    static const word_t mask = {0x7000};

#define func3(x) ((x) << 12)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                mask, 0,
                "beq", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<word_t>(i.rs1()) == core.get_reg<word_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            },
            {
                mask, func3(0b001),
                "bne", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<word_t>(i.rs1()) != core.get_reg<word_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            },
            {
                mask, func3(0b100),
                "blt", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<sword_t>(i.rs1()) < core.get_reg<sword_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            },
            {
                mask, func3(0b101),
                "bge", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<sword_t>(i.rs1()) > core.get_reg<sword_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            },
            {
                mask, func3(0b110),
                "bltu", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<word_t>(i.rs1()) < core.get_reg<word_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            },
            {
                mask, func3(0b111),
                "bgeu", SB::print,
                [] ISA_OPERATION
                {
                    sword_t value = (core.get_reg<word_t>(i.rs1()) > core.get_reg<word_t>(i.rs1())) ?
                                     i.immSB() :
                                     selen::WORD_SIZE;

                    core.increment_pc(value);
                }
            }
            };

            return product;
        }

    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << XPR::id2name(i.rs1()) << ", "
            << XPR::id2name(i.rs2()) << ", "
            << std::hex << std::showbase
            << i.immSB();
    }

}; //SB

} // namespace isa
} // namespace selen

#endif // ISA_SB_H
