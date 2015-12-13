#ifndef ISA_UI_H
#define ISA_UI_H

#include <map>
#include <functional>

#include "formats.h"

/*
 * UJ-type instruction implementation: JAL and JALR
 */

namespace selen {

namespace isa {

struct JAL
{
    enum {TARGET = OP_JAL};

    typedef formatU format_t;

    explicit JAL(format_t l) : data(l)
    {}

    void perform(State& st) const
    {

        st.reg[data.rd].u = st.pc + sizeof(instruction_t);

        st.pc = st.pc + data.get_J_immediate();
    }

    void print(std::ostream& s) const
    {
        s << "JAL\t"
          << get_regname(data.rd) << ", "
          << std::hex << std::showbase
          << data.get_J_immediate();
    }

private:
    format_t data;
}; //JAL

struct JALR
{
    enum {TARGET = OP_JALR};

    typedef formatI format_t;


    explicit JALR(format_t l) : data(l)
    {}

    void perform(State& st) const
    {
        st.reg[data.rd].u = st.pc + sizeof(instruction_t);

        st.pc = (st.reg[data.rs1].u + data.get_immediate()) & ~(1ul);
    }

    void print(std::ostream& s) const
    {
        s << "JALR\t"
          << get_regname(data.rd) << ", "
          << std::hex << std::showbase
          << data.get_immediate();
    }

private:
    format_t data;
}; //JALR

}//namespcae isa
}//namespace selen
#endif // ISA_UI_H
