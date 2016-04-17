#ifndef ISA_LOAD_H
#define ISA_LOAD_H

//LOAD-type instruction

#include "decode.h"

namespace selen
{

namespace isa
{

struct LOAD
{
    static const word_t opcode = OP_LOAD;

    //0-6 -opcode, func3 12-14
    static const word_t mask = {0x7000};

#define func3(x) ((x) << 12)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                mask, 0,
                "lb", LOAD::print,
                [] ISA_OPERATION
                {
                    sbyte_t value = core.read_mem<sbyte_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    value = (value << 24) >> 24;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b001),
                "lh", LOAD::print,
                [] ISA_OPERATION
                {
                    shword_t value = core.read_mem<shword_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    value = (value << 16) >> 16;
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b010),
                "lw", LOAD::print,
                [] ISA_OPERATION
                {
                    sword_t value = core.read_mem<sword_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b100),
                "lbu", LOAD::print,
                [] ISA_OPERATION
                {
                    byte_t value = core.read_mem<byte_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b101),
                "lhu", LOAD::print,
                [] ISA_OPERATION
                {
                    hword_t value = core.read_mem<hword_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

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
        out << XPR::id2name(i.rd()) << ","
            << std::dec << i.immI()
            << "(" << XPR::id2name(i.rs1()) << ")";
    }
}; //LOAD

} // namespace isa
} // namespace selen
#endif // ISA_LOAD_H
