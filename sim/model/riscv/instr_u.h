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
    static const word_t opcode = OP_LUI;

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "lui", LUI::print,
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

    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << std::setw(RN_WIDHT) << XPR::id2name(i.rd()) << ","
            << std::hex << std::showbase
            << i.immU();
    }
}; //LUI

struct AUIPC
{
    static const word_t opcode = OP_AUIPC;

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "auipc", LUI::print,
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
