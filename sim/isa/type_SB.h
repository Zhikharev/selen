#ifndef ISA_SB_H
#define ISA_SB_H


#include <functional>
#include <map>

#include "formats.h"

/*
 * SB-type instruction implementation
 */

namespace selen
{

namespace isa
{

struct SB
{
    enum {TARGET = OP_SB};
    typedef formatS format_t;

    explicit SB(format_t l) : data(l)
    {}

    void perform(State& st) const
    {
        link_t& r = find_link(*this);

        r.operation(st, data.rs1, data.rs2, data.get_B_immediate());
    }

    void print(std::ostream& s) const
    {
        link_t& r = find_link(*this);

        s << r.mnemonic << "\t"
          << get_regname(data.rs1) << ", "
          << get_regname(data.rs2) << ", ["
          << std::hex << std::showbase
          << data.get_B_immediate() << "]";
    }

private:

    #define OPERATION (State& st, reg_id_t s1, reg_id_t s2, addr_t imm)
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

    static link_t&  find_link(SB i)
    {
        static std::map<funct_t, link_t> link_table =
        {
            {0b000,
             {
                 "BEQ",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].s == st.reg[s2].s) ?
                              imm : sizeof(instruction_t);
                 }
             }
            },

            {0b001,
             {
                 "BNE",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].s != st.reg[s2].s) ?
                              imm : sizeof(instruction_t);
                 }
             }
            },

            {0b100,
             {
                 "BLT",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].s < st.reg[s2].s) ?
                              imm : sizeof(instruction_t);
                 }
             }
            },

            {0b110,
             {
                 "BLTU",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].u < st.reg[s2].u) ?
                              imm : sizeof(instruction_t);
                 }
             }
            },

            {0b101,
             {
                 "BGE",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].s > st.reg[s2].s) ?
                              imm : sizeof(instruction_t);
                 }
             }
            },

            {0b111,
             {
                 "BGEU",
                 []OPERATION
                 {
                     st.pc += (st.reg[s1].u > st.reg[s2].u) ?
                              imm : sizeof(instruction_t);
                 }
             }
            }

        };

        auto iter = link_table.find(i.func());

        if(iter == link_table.end())
        {
            std::ostringstream out;

            out << std::hex << std::showbase
                << "SB-type invalid func fields: "
                << "opcode= " << i.data.opcode
                << "func3= " << i.data.funct3;

            throw std::runtime_error(out.str());
        }

        return iter->second;
    }

private:
    formatS data;

#undef OPERATION
}; //R

} // namespace isa
} // namespace selen

#endif // ISA_SB_H
