#ifndef ISA_UI_H
#define ISA_UI_H

#include <map>
#include <functional>

#include "decode.h"

/*
 * UJ-type instruction implementation: JAL and JALR
 */

namespace selen
{

namespace isa
{

struct JAL
{
    static const std::vector<isa::descriptor_t>& getDescriptors()
    {
        static const std::vector<isa::descriptor_t> product =
        {
            {
                0, 0,
                "JAL", OP_JAL,
                [] ISA_OPERATION
                {
                    core.set_reg<word_t>(i.rd(), core.get_pc());
                    core.increment_pc(i.immUJ());
                }
            }
            };

        return product;
    }
}; //JAL

struct JALR
{
    static const std::vector<isa::descriptor_t>& getDescriptors()
    {
        static const std::vector<isa::descriptor_t> product =
        {
            {
                0, 0,
                "JALR", OP_JALR,
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
}; //JALR

}//namespcae isa
}//namespace selen
#endif // ISA_UI_H
