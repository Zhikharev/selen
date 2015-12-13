#ifndef STATE123456789SELEN
#define STATE123456789SELEN
/*
 * Simulator state
 */

#include <cstring>
#include "registers.h"

namespace selen
{
//sim stop when pc equal this address
constexpr addr_t SIMEXIT = 0xffffffff;

struct State
{
    //register file
    reg_t reg[NUM_REGISTERS];

    //program counter
    addr_t pc = {0};
    
    //memory
    memory_t mem;

    void clear()
    {
        pc = 0;
        mem.clear();
        ::memset(reg, 0x0, sizeof(reg));
    }
};

} // namespace selen
#endif
