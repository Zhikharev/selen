#ifndef ISA_R_H
#define ISA_R_H

#include <map>
#include <functional>

#include "formats.h"

/*
 * R-type instructions
 */

namespace selen {

namespace isa {

struct R
{
    enum {TARGET = OP_R};

    typedef formatR format_t;

    explicit R(format_t l) : data(l)
    {}


    void perform(State& st) const
    {
        link_t& r = find_link(*this);

        r.operation(st, data.rs1, data.rs2, data.rd);
        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {
        link_t& r = find_link(*this);

        s << r.mnemonic << "\t"
          << get_regname(data.rd) << ", "
          << get_regname(data.rs1) << ", "
          << get_regname(data.rs2);
    }

private:
    #define OPERATION (State& st, reg_id_t s1, reg_id_t s2, reg_id_t d)
    typedef std::function<void OPERATION> operation_t;

    struct link_t
    {
        const std::string mnemonic;
        const operation_t operation;
    };

    funct_t func() const
    {
        return ((data.funct7 << 3) | data.funct3);
    }

    static link_t& find_link(R i)
    {
        static std::map<funct_t, link_t> link_table =
        {
            {0b000,
             {
                 "ADD",
                 []OPERATION
                 {
                     st.reg[d].s = st.reg[s1].s + st.reg[s2].s;
                 }
             }
            },

            {0b010,
             {
                 "SLT",
                 []OPERATION
                 {
                     if (st.reg[s1].s < st.reg[s2].s)
                     st.reg[d].s = 1;
                 }
             }
            },

            {0b011,
             {
                 "SLTU",
                 []OPERATION
                 {
                     if (st.reg[s1].u < st.reg[s2].u)
                     st.reg[d].u = 1;
                 }
             }
            },

            {0b111,
             {
                 "AND",
                 []OPERATION
                 {
                     st.reg[d].s = st.reg[s1].s & st.reg[s2].s;
                 }
             }
            },

            {0b110,
             {
                 "OR",
                 []OPERATION
                 {
                     st.reg[d].s = st.reg[s1].s | st.reg[s2].s;
                 }
             }
            },

            {0b100,
             {
                 "XOR",
                 []OPERATION
                 {
                     st.reg[d].s = st.reg[s1].s ^ st.reg[s2].s;
                 }
             }
            },


            {0b001,
             {
                 "SLL",
                 []OPERATION
                 {//rd = rs1 << rs2[4:0]
                  st.reg[d].u = st.reg[s1].u << (st.reg[s2].u & 0xf);
                 }
             }
            },

            {0b101,
             {
                 "SRL",
                 []OPERATION
                 {//rd = rs1 >> rs2[4:0] logical shift
                  st.reg[d].u = st.reg[s1].u >> (st.reg[s2].u & 0xf);
                 }
             }
            },

            {(32u<<3)|0b000,
             {
                 "SUB",
                 []OPERATION
                 {
                     st.reg[d].s = st.reg[s1].s - st.reg[s2].s;
                 }
             }
            },

            {(32u<<3)|0b101,
             {
                 "SRA",
                 []OPERATION
                 {// ariphmetic shift
                  st.reg[d].s = st.reg[s1].s >> (st.reg[s2].u & 0xf);
                 }
             }
            },

            {(32u<<3)|0b010,
             {
                 "AM",
                 []OPERATION
                 {
                     st.reg[d].s = (st.reg[s1].s + st.reg[s2].s) / 2;
                 }
             }
            }
        };

        auto iter = link_table.find(i.func());

        if(iter == link_table.end())
        {
            std::ostringstream out;

            out << std::hex << std::showbase
                << "R-type invalid func fields: "
                << "opcode= " << i.data.opcode
                << "func3= " << i.data.funct3
                << "func7= " << i.data.funct7;

            throw std::runtime_error(out.str());
        }
        return iter->second;
    }
#undef OPERATION

private:
    format_t data;
}; //R

} // namespace isa
} // namespace selen

#endif // ISA_R_H
