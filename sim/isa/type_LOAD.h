#ifndef ISA_LOAD_H
#define ISA_LOAD_H

#include <map>
#include <functional>

#include "decode.h"

/*
 * LOAD-type instruction
 */

namespace selen
{

namespace isa
{

struct LOAD
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
                "LB", OP_LOAD,
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
                "LH", OP_LOAD,
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
                "LW", OP_LOAD,
                [] ISA_OPERATION
                {
                    sword_t value = core.read_mem<sword_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b100),
                "LBU", OP_LOAD,
                [] ISA_OPERATION
                {
                    byte_t value = core.read_mem<byte_t>(core.get_reg<word_t>(i.rs1()) + i.immI());

                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            },
            {
                mask, func3(0b101),
                "LHU", OP_LOAD,
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
}; //LOAD

} // namespace isa
} // namespace selen
#endif // ISA_LOAD_H
