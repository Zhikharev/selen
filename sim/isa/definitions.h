#ifndef ISA123456789SELEN
#define ISA123456789SELEN
/*
 * Instruction set
 */
#include <string>

#include "memory.h"
#include "../state.h"

namespace selen
{

//raw instruction represenattion
typedef word_t instruction_t;

namespace isa
{

//perform instruction (also increment pc) on the state, return disassemble representation, throw.
std::string perform(State& state, instruction_t instr);


//disassemble unstruction, nothrow
std::string disassemble(instruction_t inst);

} // namespace isa

} // namespace selen

#endif //ISA123456789SELEN
