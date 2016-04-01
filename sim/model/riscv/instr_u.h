#ifndef ISA_U_H
#define ISA_U_H

// U-type instruction: LUI and AUIPC

#include "decode.h"

namespace selen
{

namespace isa
{

struct LUI
{
    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "LUI", OP_LUI,
                [] ISA_OPERATION
                {
                    sword_t value = i.immU();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            }
            };

        return product;
    }
}; //LUI

struct AUIPC
{
    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "AUIPC", OP_AUIPC,
                [] ISA_OPERATION
                {
                    sword_t value = core.get_pc() + i.immU();
                    core.set_reg(i.rd(), value);
                    core.increment_pc();
                }
            }
            };

        return product;
    }
}; //AUIPC

} // namespace isa
} // namespace selen

#endif // ISA_U_H
