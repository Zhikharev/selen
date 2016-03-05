#ifndef ISA_U_H
#define ISA_U_H


#include <map>
#include <functional>

#include "decode.h"

/*
 * U-type instruction implementation: LUI and AUIPC
 */

namespace selen
{

namespace isa
{

struct LUI
{
    static const std::vector<isa::descriptor_t>& getDescriptors()
    {
        static const std::vector<isa::descriptor_t> product =
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
    static const std::vector<isa::descriptor_t>& getDescriptors()
    {
        static const std::vector<isa::descriptor_t> product =
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
