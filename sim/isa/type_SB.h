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
    //0-6 -opcode, func3 12-14
    static const word_t mask = {0x7000};

#define func3(x) ((x) << 12)

    static const std::vector<isa::descriptor_t>& getDescriptors()
    {
        static const std::vector<isa::descriptor_t> product =
        {
            {
                mask, 0,
                "BEQ", OP_SB,
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
                "BNE", OP_SB,
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
                "BLT", OP_SB,
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
                "BGE", OP_SB,
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
                "BLTU", OP_SB,
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
                "BGEU", OP_SB,
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
}; //SB

} // namespace isa
} // namespace selen

#endif // ISA_SB_H
