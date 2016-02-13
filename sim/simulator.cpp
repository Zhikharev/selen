#include <sstream>
#include <iomanip>
#include <iostream>
#include <cassert>

#include "simulator.h"

using namespace selen;

bool Simulator::load(memory_t &image, bool allow_resize, addr_t load_offset)
{
    size_t required_size = image.size() + load_offset;
    size_t available_size = state.mem.size();

    if(required_size > available_size)
    {
        if(!allow_resize)
            return false;

        state.mem.resize(required_size);
    }

    std::copy(image.begin(), image.end(), state.mem.data() + load_offset);

    status.image_loaded = true;

    return true;
}

std::size_t Simulator::step(size_t num_steps)
{
    status.steps_made_last = 0;
    try
    {
        if(!status.image_loaded)
            throw std::runtime_error("image was not loaded to simulator");

        cycle(num_steps);
    }
    catch(std::exception & e)
    {
        std::string line = std::string("\n") + std::string(15,'*') + std::string("\n");
        std::cerr << line
                  << "SIMULATOR ERROR: " << e.what()
                  << line
                  << std::endl;
    }

    status.steps_made_from_begin += status.steps_made_last;
    return status.steps_made_last;
}

void Simulator::cycle(const size_t steps_limit)
{
    if(config.trace)
        std::cerr << std::showbase << std::hex
                  << "Trace: " << std::endl;

    status.steps_made_last = 0;
    while (status.steps_made_last < steps_limit)
    {
        if(state.pc == selen::SIMEXIT)
            break;

        instruction_t instr = isa::fetch(state);

        //Tracing
        if(config.trace)
        {
            std::cerr << std::hex
                      << std::setw(ADR_WIDHT) << state.pc
                      << "\t" << std::setw(INST_WIDHT) << instr
                      << "\t" << isa::disassemble(instr) << std::endl;
        }

        isa::perform(state, instr);

        status.steps_made_last++;
    }
}

void Simulator::dump_registers(std::ostream& out) const
{
    out << std::showbase << std::hex;

    out << "PC:\t" << state.pc << std::endl;

    for (selen::reg_id_t id = 0; id < selen::NUM_REGISTERS; id++)
        out << regid2name(id) << ":\t"
            << state.reg[id].u << "\n";
}

void Simulator::dump_memory(std::ostream& out) const
{
    return state.mem.dump(out, state.mem.size());
}

void Simulator::set_config(const Config &econfig)
{
    config = econfig;

    if(state.mem.size() < config.mem_size)
        state.mem.resize(config.mem_size);

    state.mem.set_endian(config.endianness);
    state.pc = config.pc;
}

const Config &Simulator::get_config() const
{
    return config;
}

void Simulator::enable_tracing(bool enable)
{
    config.trace = enable;
}

const Status &Simulator::get_status() const
{
    return status;
}

addr_t Simulator::get_program_counter() const
{
    return state.pc;
}

void Simulator::set_program_counter(addr_t new_pc)
{
    state.pc = new_pc;
}

const State &Simulator::get_state() const
{
    return state;
}

std::ostream &selen::operator<<(std::ostream &os, const Config &cfg)
{
    using namespace std;

    os << setw(fmtwidht) << "tracing: " << ((cfg.trace) ? "on" : "off") << std::endl
       << setw(fmtwidht) << "endianness: " << ((cfg.endianness == selen::memory_t::LE) ? "LE" : "BE") << std::endl
       << setw(fmtwidht) << "address space size: " << cfg.mem_size << " bytes" << std::endl
       << setw(fmtwidht) << "start pc: " << cfg.pc << std::endl
       << setw(fmtwidht) << "steps: " << cfg.steps;

    return os;
}

std::ostream &selen::operator<<(std::ostream &os, const Status &st)
{
    using namespace std;

    os << setw(fmtwidht) << "program running: " << ((st.in_progress)? "yes" : "no") << endl
       << setw(fmtwidht) << "steps made from begin: " << std::dec << st.steps_made_from_begin << endl
       << setw(fmtwidht) << "steps made at last step: " << std::dec <<st.steps_made_last << endl
       << setw(fmtwidht) << "image was load: " << ((st.image_loaded) ? "yes" : "no") << endl
       << setw(fmtwidht) << "was error: " << st.was_error << "\t"
       << ((st.was_error)? st.error_description : string())  << endl
       << setw(fmtwidht) << "return code: " << std::dec << st.return_code;

    return os;
}
