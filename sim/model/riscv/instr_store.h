#ifndef ISA_STORE_H
#define ISA_STORE_H

// STORE-type instruction

#include "decode.h"

namespace selen
{

namespace isa
{

struct STORE
{
    static const word_t opcode = OP_STORE;

    //0-6 -opcode, func3 12-14
    static const word_t mask = {0x7000};

#define func3(x) ((x) << 12)

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                mask, 0,
                "sb", STORE::print,
                [] ISA_OPERATION
                {
                    byte_t value = core.get_reg<byte_t>(i.rs2());

                    core.write_mem(core.get_reg<word_t>(i.rs1()) + i.immS(), value);

                    core.increment_pc();
                }
            },
            {
                mask, func3(0b001),
                "sh", STORE::print,
                [] ISA_OPERATION
                {
                    shword_t value = core.get_reg<shword_t>(i.rs2());

                    core.write_mem(core.get_reg<word_t>(i.rs1()) + i.immS(), value);

                    core.increment_pc();
                }
            },
            {
                mask, func3(0b010),
                "sw", STORE::print,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_reg<sword_t>(i.rs2());

                    core.write_mem(core.get_reg<word_t>(i.rs1()) + i.immS(), value);

                    core.increment_pc();
                }
            }

            };

            return product;
        }

    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << XPR::id2name(i.rs1()) << ","
            << std::dec << i.immS() << "("
            << XPR::id2name(i.rs2()) << ")";
    }

}; //STORE

} // namespace isa
} // namespace selen


#endif // ISA_STORE_H
