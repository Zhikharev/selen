#ifndef MODEL_RISCV_DISASSEMBLER_H_
#define MODEL_RISCV_DISASSEMBLER_H_

#include <iomanip>
#include <ostream>
#include <string>

#include "../defines.h"

namespace selen
{

namespace isa
{

//disassemble instruction, nothrow, if error print "invalid instruction"
std::string disassemble(const word_t instruction);

//dumper for memory_t::dump()
struct disasembler_dumper
{
    typedef word_t token_t;

    void inline operator()(token_t token, std::ostream& out)
    {
        out << std::setw(10) << token
            << "\t"
            << disassemble(token);
    }
};

} // namespace isa

} // namespace selen


#endif /* MODEL_RISCV_DISASSEMBLER_H_ */
