#ifndef ISA_U_H
#define ISA_U_H


#include <map>
#include <functional>

#include "formats.h"

/*
 * U-type instruction implementation: LUI and AUIPC
 */

namespace selen {

namespace isa {

struct LUI
{
    enum {TARGET = OP_LUI};

    typedef formatU format_t;

    explicit LUI(format_t l) : data(l)
    {}

    void perform(State& st) const
    {
        st.reg[data.rd].u = data.get_U_immediate();

        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {
        s << std::setw(MF_WIDHT) << "LUI" << "\t"
          << std::setw(RN_WIDHT) << regid2name(data.rd) << ", "
          << std::hex << std::showbase
          << data.get_U_immediate();
    }

private:
    format_t data;
}; //LUI

struct AUIPC
{
    enum {TARGET = OP_AUIPC};

    typedef formatU format_t;


    explicit AUIPC(format_t l) : data(l)
    {}

    void perform(State& st) const
    {
        st.reg[data.rd].u =  st.pc + data.get_U_immediate();

        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {
        s << std::setw(MF_WIDHT) << "AUIPC"
          << std::setw(RN_WIDHT) << regid2name(data.rd) << ", "
          << std::hex << std::showbase
          << data.get_U_immediate();
    }

private:
    format_t data;
}; //AUIPC

} // namespace isa
} // namespace selen

#endif // ISA_U_H
