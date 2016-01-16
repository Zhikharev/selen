#ifndef ISA123456789SELEN
#define ISA123456789SELEN
/*
 * Instruction set
 */
#include <string>
#include <ostream>

#include "memory.h"
#include "../state.h"


//Bits extraction
//least n bits
#define bit_least(val,n) ((val) & ((1<<(n))-1))
//extract sequence, start inclusive, stop exclusive
#define bit_seq(val,start,stop) bit_least((val)>>(start),((stop)-(start)))

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

//raw instruction represenattion
typedef word_t instruction_t;

namespace isa
{

//perform instruction (also increment pc) on the state, throw.
void perform(State& state, const instruction_t instr);


//disassemble unstruction, nothrow
std::string disassemble(const instruction_t inst);


//dumper for memory_t::dump()
struct disasembler_dumper
{
    typedef selen::instruction_t token_t;

    void inline operator()(selen::instruction_t token, std::ostream& out)
    {
        out << std::setw(10) << token
            << "\t"
            << selen::isa::disassemble(token);
    }
};

} // namespace isa

} // namespace selen

#endif //ISA123456789SELEN
