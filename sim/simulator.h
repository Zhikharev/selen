#ifndef SIMULATOR123456789SELEN
#define SIMULATOR123456789SELEN

#include <cassert>
#include <string>
#include "state.h"
#include "isa/definitions.h"

namespace selen
{

struct Config
{
    //memory size (bytes)
    std::size_t mem_size;
    
    //entry program counter value
    addr_t pc;
    //enable tracing
    bool trace;

    //num steps
    size_t steps;

    //image source
    std::string imagefilename;

    //dump destination
    std::string dumpfile;

    //endian
    memory_t::ENDIAN endianness = {memory_t::LE};
};

class Simulator
{
public:
    Simulator(Config &conf) :
        m_config(conf)
    {
        m_state.clear();
        m_state.mem.set_endian(conf.endianness);
    }
    
    //load image to memory
    void load(memory_t &image);
    
    //run simulator
    std::size_t step(size_t num_steps);
    
    //dump registers and memory to stream
    void dump_registers(std::ostream& out);
    void dump_memory(std::ostream& out);

private:
    void cycle(size_t num_steps, size_t &steps_made);
    instruction_t fetch();
    
    State  m_state;
    Config m_config;
};

} //namespace selen
#endif //SIMULATOR123456789SELEN
