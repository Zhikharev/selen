#ifndef ISA_LOAD_H
#define ISA_LOAD_H

#include <map>
#include <functional>

#include "formats.h"

/*
 * LOAD-type instruction implementation
 */

namespace selen {

namespace isa {

struct LOAD
{
    enum {TARGET = OP_LOAD};

    typedef formatI format_t;

    explicit LOAD(format_t l) : data(l)
    {}


    void perform(State& st) const
    {
        link_t& r = find_link(*this);

        r.operation(st, data.rs1, data.get_immediate(), data.rd);
        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {
        link_t& r = find_link(*this);

        s << std::setw(MF_WIDHT) << r.mnemonic << "\t"
          << std::setw(RN_WIDHT) << regid2name(data.rd) << ", ["
          << std::setw(RN_WIDHT) << regid2name(data.rs1) << " + "
          << std::hex << std::showbase
          << data.get_immediate() << "]";
    }

private:
    #define OPERATION (State& st, reg_id_t s1, addr_t imm, reg_id_t d)
    typedef std::function<void OPERATION> operation_t;

    struct link_t
    {
        const std::string mnemonic;
        const operation_t operation;
    };

    funct_t func() const
    {
        return data.funct3;
    }

    static link_t& find_link(LOAD i)
    {
        static std::map<funct_t, link_t> link_table =
        {
            {0b010,
             {
                 "LW",
                 []OPERATION
                 {
                     st.reg[d].s = st.mem.read<word_t>(st.reg[s1].u + imm);
                 }
             }
            },

            {0b001,
             {
                 "LH",
                 []OPERATION
                 {
                     st.reg[d].s = st.mem.read<shword_t>(st.reg[s1].u + imm);
                 }
             }
            },

            {0b101,
             {
                 "LHU",
                 []OPERATION
                 {
                     st.reg[d].u = st.mem.read<hword_t>(st.reg[s1].u + imm);
                 }
             }
            },

            {0b000,
             {
                 "LB",
                 []OPERATION
                 {
                     st.reg[d].s = st.mem.read<sbyte_t>(st.reg[s1].u + imm);
                 }
             }
            },

            {0b100,
             {
                 "LBU",
                 []OPERATION
                 {
                     st.reg[d].u = st.mem.read<byte_t>(st.reg[s1].u + imm);
                 }
             }
            }
        };

        auto iter = link_table.find(i.func());

        if(iter == link_table.end())
        {
            std::ostringstream out;

            out << std::hex << std::showbase
                << "LOAD-type invalid func3 field: "
                << "opcode= " << i.data.opcode
                << "func3= " << i.data.funct3;
            throw std::runtime_error(out.str());
        }

        return iter->second;
    }
#undef OPERATION

private:
    format_t data;
}; //LOAD

} // namespace isa
} // namespace selen
#endif // ISA_LOAD_H
