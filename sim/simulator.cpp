#include <sstream>
#include <iomanip>
#include <iostream>
#include <cassert>

#include "simulator.h"

using namespace selen;

void Simulator::load(memory_t &image)
{
    assert(!image.empty());

    m_state.mem.swap(image);
    if(m_state.mem.size() < m_config.mem_size)
        m_state.mem.resize(m_config.mem_size);
}

std::size_t Simulator::step(size_t num_steps)
{
    m_state.pc = m_config.pc;

    size_t steps_made = 0;

    try
    {
        cycle(num_steps, steps_made);
    }
    catch(std::exception & e)
    {
        std::string line = std::string("\n") + std::string(15,'*') + std::string("\n");
        std::cerr << line
                  << "SIMULATOR ERROR: " << e.what()
                  << line
                  << std::endl;
    }

    return steps_made;
}

void Simulator::cycle(size_t steps_limit, size_t& steps_made)
{
    if(m_config.trace)
        std::cerr << std::showbase << std::hex
                  << "Trace: " << std::endl;

    steps_made = 0;
    while (steps_made < steps_limit)
    {
        if(m_state.pc == selen::SIMEXIT)
            break;

        instruction_t instr = fetch();

        std::string mnemonic = isa::perform(m_state, instr);

        //Tracing
        if(m_config.trace)
        {
            std::cerr << std::hex <<
                m_state.pc <<
                "\t" << instr <<
                "\t" << mnemonic << std::endl;
        }
        steps_made++;
    }
}

instruction_t Simulator::fetch()
{
    if(m_state.pc > m_state.mem.size() + selen::WORD_SIZE)
        throw std::runtime_error("PC refers to invalid address: "
                                 "out of memory range");

    return m_state.mem.read<word_t>(m_state.pc);
}

void Simulator::dump_registers(std::ostream& out)
{
    out << std::showbase << std::hex;

    out << "PC:\t" << m_state.pc << std::endl;

    for (selen::reg_id_t id = 0; id < selen::NUM_REGISTERS; id++)
        out << get_regname(id) << ":\t"
            << m_state.reg[id].u << "\n";
}

void Simulator::dump_memory(std::ostream& out)
{
    return m_state.mem.dump(out);
}
