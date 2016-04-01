/**
 * Selen 2016
 *
 * model lib source file,
 *
 * try to keep it as one compilation unit
 */

#include <map>
#include <sstream>
#include <memory>
#include <tuple>
#include <algorithm>
#include <unordered_map>
#include <cassert>
#include <iomanip>

#include "model.h"

using namespace selen;
using namespace std;

//======================================
// ISA
//======================================

//opcode -> vector of specific descriptors for that opcode
typedef std::unordered_map<word_t, const isa::descriptor_array_t&> descriptors_table_t;

inline const descriptors_table_t& get_descriptors()
{
    using namespace isa;

    static descriptors_table_t product =
        {
            {OP_R, R::getDescriptors()},
            {OP_I_R, I_R::getDescriptors()},
            {OP_LUI,  LUI::getDescriptors()},
            {OP_AUIPC, AUIPC::getDescriptors()},
            {OP_SB, SB::getDescriptors()},
            {OP_JAL, JAL::getDescriptors()},
            {OP_JALR, JALR::getDescriptors()},
            {OP_LOAD, LOAD::getDescriptors()},
            {OP_STORE, STORE::getDescriptors()}
        };

    return product;
}

isa::descriptor_t invalidDescriptor =
{
    0, 0, "invalid", 0,
    []
    ISA_OPERATION
    {
        std::ostringstream out;

        out << "invalid instruction: "
            << hex << showbase
            << i
            << ", op: " << i.opcode()
            << " rd: " << dec << i.rd()
            << " rs1:" << dec << i.rs1()
            << " rs2:" << dec << i.rs2()
            << " rm:" << hex << i.rm();

        throw std::runtime_error(out.str());
    }
};

std::string isa::print_instruction(const std::string& mnemonic,
                                   const word_t format,
                                   const isa::instruction_t i)
{
    std::ostringstream s;
    s << std::setw(MF_WIDHT) << mnemonic << "\t";

    switch(format)
    {
    case OP_R:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", "
          << std::setw(RN_WIDHT) << regid2name(i.rs1()) << ", "
          << regid2name(i.rs2());
        break;

    case OP_I_R:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", "
          << std::setw(RN_WIDHT) << regid2name(i.rs1()) << ", "
          << std::dec << std::showbase
          << i.immI();
        break;

    case OP_AUIPC:
    case OP_LUI:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", "
          << std::hex << std::showbase
          << i.immU();
        break;

    case OP_SB:
        s << std::setw(RN_WIDHT) << regid2name(i.rs1()) << ", "
          << std::setw(RN_WIDHT) << regid2name(i.rs2()) << ", ["
          << std::dec << std::showbase
          << i.immSB()
          << " (" << std::hex << i.immSB() << ")]";

    case OP_JAL:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", "
          << std::hex << std::showbase
          << i.immUJ();
        break;

    case OP_JALR:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", "
          << regid2name(i.rs1()) << ", "
          << std::hex << std::showbase
          << i.immI();
        break;

    case OP_LOAD:
        s << std::setw(RN_WIDHT) << regid2name(i.rd()) << ", ["
          << std::setw(RN_WIDHT) << regid2name(i.rs1()) << " + "
          << std::hex << std::showbase
          << i.immI() << "]";
        break;

    case OP_STORE:
        s << std::setw(RN_WIDHT) << regid2name(i.rs1()) << ", ["
          << std::setw(RN_WIDHT) << regid2name(i.rs2()) << " + "
          << std::hex << std::showbase
          << i.immS() << "]";
        break;

    }

    return s.str();
}

isa::descriptor_ptr_t find_descriptor(const isa::instruction_t& instruction)
{
    static const descriptors_table_t descriptors = get_descriptors();

    isa::descriptor_ptr_t product = nullptr;

    auto iter = descriptors.find(instruction.opcode());

    if(iter == descriptors.end())
        return product;

    const vector<isa::descriptor_t>& section = iter->second;

    for(const isa::descriptor_t& candidate : section)
    {
        if(candidate == instruction)
        {
            product = &candidate;
            break;
        }
    }

    return product;
}

isa::fetch_t inline decode(const isa::instruction_t &instr)
{
    isa::descriptor_ptr_t descriptor = find_descriptor(instr);

    if(descriptor == nullptr)
        descriptor = &invalidDescriptor;

    return isa::fetch_t{instr, descriptor};
}

std::string isa::disassemble(const word_t instr)
{
    return decode(instr).disasemble();
}

const std::vector<string>& selen::get_reg_names()
{
    static std::vector<std::string> names =
    {
        "zero",
        "ra",
        "sp", "gp",
        "tp", "t0", "t1", "t2",
        "s0", "s1",
        "a0", "a1", "a2", "a3", "a4", "a5","a6", "a7",
        "s2", "s3", "s4", "s5", "s6", "s7","s8", "s9", "s10", "s11",
        "t3", "t4", "t5", "t6"
    };

    return names;
}

std::string selen::regid2name(const reg_id_t id)
{
    const std::vector<std::string>& names = get_reg_names();

    if(id >= R_LAST)
        throw std::invalid_argument("bad register id");

    return names.at(id);
}

reg_id_t selen::name2regid(const std::string &name)
{
    const std::vector<std::string>& names = get_reg_names();

    std::string NAME;
    std::transform(name.begin(), name.end(), std::back_inserter(NAME), ::toupper);

    for (size_t i = 0; i < names.size(); i++)
    {
        if(names.at(i) == NAME)
            return static_cast<reg_id_t>(i);
    }

    return selen::R_LAST;
}

//======================================
// Core
//======================================

selen::word_t selen::Core::fetch() const
{
    assert(mem != nullptr);

    const addr_t pc = get_pc();
    if(pc > mem->size() + selen::WORD_SIZE)
        throw std::runtime_error("PC refers to invalid address: "
                                 "out of memory range");

    return read_mem<word_t>(pc);
}

void selen::Core::step()
{
    word_t instr = fetch();
    isa::fetch_t action = decode(instr);

    if(trace != nullptr)
        trace->write(trace::RInsFetch{get_pc(), action});

    action(*this);
}

void selen::CoreState::dump(std::ostream& out) const
{
    out << "PC:\t" << std::hex << pc << std::endl;

    for (selen::reg_id_t id = 0; id < selen::NUM_REGISTERS; id++)
        out << regid2name(id) << ":\t"
            << reg.read<word_t>(id) << std::endl;
}

selen::addr_t selen::Core::get_pc() const
{
    return state.pc;
}

void selen::Core::set_pc(const addr_t pc)
{
    state.pc = pc;
}

void selen::Core::increment_pc(const sword_t value)
{
    state.pc += value;
}

const selen::CoreState& selen::Core::get_state() const
{
    return state;
}

void selen::Core::init(memory_t* region)
{
    mem = region;
}

//======================================
// Model
//======================================

using namespace selen;

bool Model::load(const std::vector<byte_t>& image, bool allow_resize, addr_t load_offset)
{
    const size_t required_size = image.size() + load_offset;
    const size_t available_size = memory.size();

    if(required_size > available_size)
    {
        if(!allow_resize)
            return false;

        memory.resize(required_size);
    }

    memory.load(image.data(), image.size(), load_offset);

    status.image_loaded = true;

    return true;
}

std::size_t Model::step(const size_t num_steps)
{
    status.steps_made_last = 0;
    try
    {
        if(!config.isDPI && !status.image_loaded)
            throw std::runtime_error("image was not loaded to simulator");

        cycle(num_steps);
    }
    catch(std::exception & e)
    {
        //rethrow forward if model is a dpi lib
        if(config.isDPI)
            throw;

        std::string line = std::string("\n") + std::string(15,'*') + std::string("\n");
        std::cerr << line
                  << "SIMULATOR ERROR: " << e.what()
                  << line
                  << std::endl;
    }

    status.steps_made_from_begin += status.steps_made_last;
    return status.steps_made_last;
}

void Model::cycle(const size_t steps_limit)
{
    status.steps_made_last = 0;
    while (status.steps_made_last < steps_limit)
    {
        core.step();

        status.steps_made_last++;
    }
}

void Model::dump_state(std::ostream& out) const
{
    core.get_state().dump(out);
    memory.dump(out, memory.size());
}

void Model::set_config(const Config &econfig)
{
    core.reset();

    trace.reset(econfig.trace_config);

    core.set_trace((econfig.trace) ? &trace : nullptr);
    config = econfig;

    if(memory.size() < config.mem_size)
        memory.resize(config.mem_size);

    memory.set_endian(config.endianness);
    core.set_pc(config.pc);
}

const Config &Model::get_config() const
{
    return config;
}

void Model::enable_tracing(const bool enable)
{
    config.trace = enable;
    core.set_trace((enable) ? &trace : nullptr);
}

const Status &Model::get_status() const
{
    return status;
}

addr_t Model::get_program_counter() const
{
    return core.get_pc();
}

void Model::set_program_counter(const addr_t value)
{
    core.set_pc(value);
}

const CoreState& Model::get_core_state() const
{
    return core.get_state();
}

const memory_t& Model::get_memory() const
{
    return memory;
}

std::ostream &selen::operator<<(std::ostream &os, const Config &cfg)
{
    using namespace std;

    os << setw(FMT_WIDHT) << "tracing: " << ((cfg.trace) ? "on" : "off") << std::endl
       << setw(FMT_WIDHT) << "endianness: " << ((cfg.endianness == selen::memory_t::LE) ? "LE" : "BE") << std::endl
       << setw(FMT_WIDHT) << "address space size: " << cfg.mem_size << " bytes" << std::endl
       << setw(FMT_WIDHT) << "start pc: " << cfg.pc << std::endl
       << setw(FMT_WIDHT) << "steps: " << cfg.steps;

    return os;
}

std::ostream &selen::operator<<(std::ostream &os, const Status &st)
{
    using namespace std;

    os << setw(FMT_WIDHT) << "program running: " << ((st.in_progress)? "yes" : "no") << endl
       << setw(FMT_WIDHT) << "steps made from begin: " << std::dec << st.steps_made_from_begin << endl
       << setw(FMT_WIDHT) << "steps made at last step: " << std::dec <<st.steps_made_last << endl
       << setw(FMT_WIDHT) << "image was load: " << ((st.image_loaded) ? "yes" : "no") << endl
       << setw(FMT_WIDHT) << "was error: " << st.was_error << "\t"
       << ((st.was_error)? st.error_description : string())  << endl
       << setw(FMT_WIDHT) << "return code: " << std::dec << st.return_code;

    return os;
}
