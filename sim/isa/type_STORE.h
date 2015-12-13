#ifndef ISA_STORE_H
#define ISA_STORE_H

#include <map>
#include <functional>

#include "formats.h"
/*
 * STORE-type instruction implementation
 */

namespace selen {

namespace isa {

struct STORE
{
    enum {TARGET = OP_STORE};

    typedef formatS format_t;

    explicit STORE(format_t l) : data(l)
    {}

    void perform(State& st) const
    {
        link_t& r = find_link(*this);

        r.operation(st, data.rs1, data.rs2, data.get_S_immediate());;
        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {
        link_t& r = find_link(*this);

        s << r.mnemonic << "\t"
            << get_regname(data.rs1) << ", ["
            << get_regname(data.rs2) << " + "
            << std::hex << std::showbase
            << data.get_S_immediate() << "]";
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

    static link_t& find_link(STORE i)
    {
        static std::map<funct_t, link_t> link_table =
        {
            {0b010,
             {
                 "SW",
                 []OPERATION
                 {
                     st.mem.write<word_t>(st.reg[s2].u + imm, st.reg[s1].u);
                 }
             }
            },

            {0b001,
             {
                 "SH",
                 []OPERATION
                 {
                     st.mem.write<hword_t>(st.reg[s2].u + imm, st.reg[s1].hw[0]);
                 }
             }
            },

            {0b000,
             {
                 "SB",
                 []OPERATION
                 {
                     st.mem.write<byte_t>(st.reg[s2].u + imm, st.reg[s1].b[0]);
                 }
             }
            }
        };

        auto iter = link_table.find(i.func());

        if(iter == link_table.end())
        {
            std::ostringstream out;

            out << std::hex << std::showbase
                << "STORE-type invalid func3 field: "
                << "opcode= " << i.data.opcode
                << "func3= " << i.data.funct3;

            throw std::runtime_error(out.str());
        }
        return iter->second;
    }
#undef OPERATION

private:
    format_t data;
}; //STORE

} // namespace isa
} // namespace selen


#endif // ISA_STORE_H
