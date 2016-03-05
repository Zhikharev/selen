#ifndef ISA123456789SELEN
#define ISA123456789SELEN
/*
 * Instruction set
 */
#include <string>
#include <ostream>

#include "memory.h"
#include "../core.h"

//Bits extraction
//least n bits
#define bit_least(val, n) ((val) & ((1 << (n)) - 1))

//extract sequence, begin inclusive, end exclusive
#define bit_seq(val, begin, end) bit_least((val) >> (begin), ((end) - (begin)))

//disasembler formated output

//mnemonic field widht
#define MF_WIDHT 6
//regname field widht
#define RN_WIDHT 3
//address field widht
#define ADR_WIDHT 12
//instruction field widht
#define INST_WIDHT 12
//

namespace selen
{

namespace isa
{

//perform instruction (also increment pc) on the state, throw.
void perform(selen::Core& core, const word_t instruction);

//disassemble unstruction, nothrow
std::string disassemble(const word_t instruction);

//dumper for memory_t::dump()
struct disasembler_dumper
{
    typedef word_t token_t;

    void inline operator()(token_t token, std::ostream& out)
    {
        out << std::setw(10) << token
            << "\t"
            << selen::isa::disassemble(token);
    }
};

} // namespace isa

} // namespace selen

#endif //ISA123456789SELEN
