#include <sstream>
#include <iomanip>
#include <iostream>
#include <cassert>

#include "simulator.h"

using namespace selen;

bool Machine::load(memory_t &image, bool allow_resize, addr_t load_offset)
{
    const size_t required_size = image.size() + load_offset;
    const size_t available_size = memory.size();

    if(required_size > available_size)
    {
        if(!allow_resize)
            return false;

        memory.resize(required_size);
    }

    std::copy(image.begin(), image.end(), memory.data() + load_offset);

    status.image_loaded = true;

    return true;
}

std::size_t Machine::step(size_t num_steps)
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

void Machine::cycle(const size_t steps_limit)
{
    if(config.trace)
        std::cerr << std::showbase << std::hex
                  << "Trace: " << std::endl;

    status.steps_made_last = 0;
    while (status.steps_made_last < steps_limit)
    {
        //Tracing
        if(config.trace)
        {
            word_t instr = core.fetch();
            std::cerr << std::hex
                      << std::setw(ADR_WIDHT) << core.get_pc()
                      << "\t" << std::setw(INST_WIDHT) << instr
                      << "\t" << isa::disassemble(instr) << std::endl;
        }

        core.step();

        status.steps_made_last++;
    }
}

void Machine::dump_registers(std::ostream& out) const
{
    out << std::showbase;

    const CoreState& state = core.get_state();

    out << "PC:\t" << std::hex << state.pc << std::endl;

    for (selen::reg_id_t id = 0; id < selen::NUM_REGISTERS; id++)
        out << regid2name(id) << ":\t"
            << state.reg.read<word_t>(id) << std::endl;
}

void Machine::dump_memory(std::ostream& out) const
{
    return memory.dump(out, memory.size());
}

void Machine::set_config(const Config &econfig)
{
    core.reset();

    config = econfig;

    if(memory.size() < config.mem_size)
        memory.resize(config.mem_size);

    memory.set_endian(config.endianness);
    core.set_pc(config.pc);
}

const Config &Machine::get_config() const
{
    return config;
}

void Machine::enable_tracing(const bool enable)
{
    config.trace = enable;
}

const Status &Machine::get_status() const
{
    return status;
}

addr_t Machine::get_program_counter() const
{
    return core.get_pc();
}

void Machine::set_program_counter(const addr_t value)
{
    core.set_pc(value);
}

const CoreState& Machine::get_core_state() const
{
    return core.get_state();
}

const memory_t& Machine::get_memory() const
{
    return memory;
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
