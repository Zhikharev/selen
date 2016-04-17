#ifndef ISA_UI_H
#define ISA_UI_H

// UJ-type instruction : JAL and JALR

#include "decode.h"

namespace selen
{

namespace isa
{

struct JAL
{
    static const word_t opcode = OP_JAL;

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "jal", JAL::print,
                [] ISA_OPERATION
                {
                    core.set_reg<word_t>(i.rd(), core.get_pc());
                    core.increment_pc(i.immUJ());
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
            << i.immUJ();
    }
}; //JAL

struct JALR
{
    static const word_t opcode = OP_JALR;

    static const descriptor_array_t& getDescriptors()
    {
        static const descriptor_array_t product =
        {
            {
                0, 0,
                "jalr", JALR::print,
                [] ISA_OPERATION
                {
                    core.set_reg<word_t>(i.rd(), core.get_pc());
                    sword_t value = (core.get_reg<sword_t>(i.rs1()) + i.immI()) & ~(1ul);
                    core.set_pc(value);
                }
            }
            };

        return product;
    }

    static void print(std::ostream& out,
                      const instruction_t i)
    {
        out << std::setw(RN_WIDHT) << XPR::id2name(i.rd()) << ","
            << std::dec << i.immI()
            << "(" << XPR::id2name(i.rs1()) << ")";
    }
}; //JALR

}//namespcae isa
}//namespace selen
#endif // ISA_UI_H
