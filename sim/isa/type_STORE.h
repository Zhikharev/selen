#ifndef ISA_STORE_H
#define ISA_STORE_H

#include <map>
#include <functional>

#include "decode.h"
/*
 * STORE-type instruction implementation
 */

namespace selen
{

namespace isa
{

struct STORE
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
                "SB", OP_STORE,
                [] ISA_OPERATION
                {
                    byte_t value = core.get_reg<byte_t>(i.rs2());

                    core.write_mem(core.get_reg<word_t>(i.rs1()) + i.immS(), value);

                    core.increment_pc();
                }
            },
            {
                mask, func3(0b001),
                "SH", OP_STORE,
                [] ISA_OPERATION
                {
                    shword_t value = core.get_reg<shword_t>(i.rs2());

                    core.write_mem(core.get_reg<word_t>(i.rs1()) + i.immS(), value);

                    core.increment_pc();
                }
            },
            {
                mask, func3(0b010),
                "SW", OP_STORE,
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
}; //STORE


} // namespace isa
} // namespace selen


#endif // ISA_STORE_H
