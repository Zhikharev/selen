#include <map>
#include <sstream>
#include <memory>
#include <tuple>

#include "handlers.h"

#include "type_R.h"
#include "type_I_R.h"
#include "type_U.h"
#include "type_SB.h"
#include "type_UJ.h"
#include "type_LOAD.h"
#include "type_STORE.h"


using namespace selen;
using namespace std;

//table of handlers.
typedef map<isa::opcode_t, isa::handler_t*> handlers_table_t;

std::string selen::get_regname(reg_id_t id)
{
    static std::string names[] =
    {
        "ZERO",
        "AT",
        "V0", "V1",
        "A0", "A1", "A2", "A3",
        "T0", "T1", "T2", "T3", "T4",
        "T5", "T6", "T7",
        "S0", "S1", "S2", "S3",
        "S4", "S5", "S6", "S7",
        "T8", "T9",
        "K0", "K1",
        "GP", "SP",
        "FP",
        "RA",
    };

    if(id >= R_LAST)
        throw std::invalid_argument("bad register id");

    return names[id];
}

handlers_table_t inline init_handlers()
{
    using namespace isa;

    static tuple<
            Handler<R>,
            Handler<I_R>,
            Handler<LUI>,
            Handler<AUIPC>,
            Handler<SB>,
            Handler<JAL>,
            Handler<JALR>,
            Handler<LOAD>,
            Handler<STORE>
            > handlers;

    return handlers_table_t
        {
            {OP_R,      &get<0>(handlers)},
            {OP_I_R,    &get<1>(handlers)},
            {OP_LUI,    &get<2>(handlers)},
            {OP_AUIPC,  &get<3>(handlers)},
            {OP_SB,     &get<4>(handlers)},
            {OP_JAL,    &get<5>(handlers)},
            {OP_JALR,   &get<6>(handlers)},
            {OP_LOAD,   &get<7>(handlers)},
            {OP_STORE,  &get<8>(handlers)}
        };
}

isa::opcode_t extract_opcode(instruction_t instr)
{
     return bit_seq(instr, 0, 7);
}

isa::handler_t& get_handler(instruction_t instr, addr_t pc)
{
    static handlers_table_t handlers = init_handlers();

    using namespace isa;

    opcode_t op = ::extract_opcode(instr);

    auto iter = handlers.find(op);
    if(iter == handlers.end())
    {
        std::ostringstream out;

        out << hex << showbase
            << "illegal opcode " << (op&0xff)
            << ", unable decode instruction: " << instr
            << " at address " << pc + WORD_SIZE <<"\n"
            << "valid opcodes:\n";

        for(auto token: handlers)
            out << (token.first&0xff) <<"\t";


        throw runtime_error(out.str());
    }

    return (*iter->second);
}

//disassembler variant
isa::handler_t& get_handler(instruction_t instr)
{
    static handlers_table_t handlers = init_handlers();

    using namespace isa;

    opcode_t op = ::extract_opcode(instr);

    auto iter = handlers.find(op);


    if(iter == handlers.end())
    {
        std::ostringstream out;

        out << hex << showbase
            << "invalid, opcode: " << (op&0xff);

        throw std::runtime_error(out.str());
    }

    return (*iter->second);
}

std::string isa::perform(State& state, instruction_t instr)
{
    handler_t& h = get_handler(instr, state.pc);
    h.perform(state, instr);

    return h.disasemble(instr);
}


std::string isa::disassemble(instruction_t instr)
{
    std::string product;

    try
    {
        handler_t& h = get_handler(instr);

        product = h.disasemble(instr);
    }
    catch(std::exception& e)
    {
        product = e.what();
    }

    return product;
}
