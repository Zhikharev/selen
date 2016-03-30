#include <map>
#include <sstream>
#include <memory>
#include <tuple>
#include <algorithm>
#include <unordered_map>

#include "type_R.h"
#include "type_I_R.h"
#include "type_U.h"
#include "type_SB.h"
#include "type_UJ.h"
#include "type_LOAD.h"
#include "type_STORE.h"
#include "decode.h"

using namespace selen;
using namespace std;

//opcode -> vector of specific descriptors for that opcode
typedef std::unordered_map<word_t, const vector<isa::descriptor_t>&> descriptors_table_t;

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

void isa::perform(selen::Core& core, const word_t instr)
{
    fetch_t f = decode(instr);

    f(core);
}

std::string isa::disassemble(const word_t instr)
{
    return decode(instr).disasemble();
}

void selen::Core::step()
{
    word_t instr = fetch();
    isa::fetch_t f = decode(instr);

    if(trace != nullptr)
        trace->write(InsFetchRecord{get_pc(), f});

    f(*this);
    //selen::isa::perform(*this, instr);
}

//---------------------------------------------------

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
