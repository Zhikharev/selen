#ifndef ISA_I_R_H
#define ISA_I_R_H

#include <functional>
#include <map>

#include "formats.h"

/*
 * I_R-type instruction implementation
 */

namespace selen
{

namespace isa
{

struct I_R
{
    enum {TARGET = OP_I_R};

    typedef formatI format_t;

    explicit I_R(formatI i)
    {
        data.i = i;
    }

    #define OPERATION (State& st, reg_id_t s1, sword_t imm, reg_id_t d)
    typedef std::function<void OPERATION> operation_t;

    void perform(State& st) const
    {
        const link_t& r = find_link(*this);

        r.operation(st, data.i.rs1, data.i.get_immediate(), data.i.rd);
        st.pc = st.pc + sizeof(instruction_t);
    }

    void print(std::ostream& s) const
    {

        const link_t& r = find_link(*this);

        s << std::setw(MF_WIDHT) << r.mnemonic << "\t"
          << std::setw(RN_WIDHT) << regid2name(data.i.rd) << ", "
          << std::setw(RN_WIDHT) << regid2name(data.i.rs1) << ", "
          << std::hex << std::showbase
          << data.i.get_immediate();
    }

private:
    struct link_t
    {
        const std::string mnemonic;
        const operation_t operation;
    };

    enum links_selector_t
    {
        linksI = 0,
        linksR = 1
    };

    funct_t func(links_selector_t selector) const
    {
        if(selector == linksI)
            return data.i.funct3;

        return ((data.r.funct7 << 3) | data.r.funct3);
    }

    bool maybe_R_type() const
    {
        return (data.r.funct7 == 0000000 || data.r.funct7 == 0b0100000);
    }

     static  const link_t& find_link(I_R i)
    {
        static std::map<funct_t, link_t> link_table[2] =
        {

            {//I table
                {0b000,
                    {
                        "ADDI",
                        []OPERATION
                        {
                            st.reg[d].s = st.reg[s1].s + imm;
                        }
                    }
                },

                {0b010,
                    {
                        "SLTI",
                        []OPERATION
                        {
                            if (st.reg[s1].s < imm)
                            st.reg[d].s = 1;
                        }
                    }
                },

                {0b111,
                    {
                        "ANDI",
                        []OPERATION
                        {
                            st.reg[d].s = st.reg[s1].s & imm;
                        }
                    }
                },

                {0b110,
                    {
                        "ORI",
                        []OPERATION
                        {
                            st.reg[d].s = st.reg[s1].s | imm;
                        }
                    }
                },

                {0b100,
                    {
                        "XORI",
                        []OPERATION
                        {
                            st.reg[d].s = st.reg[s1].s ^ imm;
                        }
                    }
                }
            },//end I table

            //******

            {//R table
                 {0b001,
                      {
                          "SLLI",
                          []OPERATION
                          {
                              st.reg[d].u = st.reg[s1].u << (bit_seq(imm, 0, 6));
                          }
                      }
                 },

                 {0b101,
                      {
                          "SRLI",
                          []OPERATION
                          {
                              st.reg[d].u = st.reg[s1].u >> (bit_seq(imm, 0, 6));
                          }
                      }
                 },

                 {(32u<<3)|0b101,
                      {
                          "SRAI",
                          []OPERATION
                          {
                              st.reg[d].s = st.reg[s1].s >> (bit_seq(imm, 0, 6));
                          }
                      }
                 }
            }//end R table

        };//end link table

        //search R type
        if(i.maybe_R_type())
        {
            auto iterR = link_table[linksR].find(i.func(linksR));

            if(iterR != link_table[linksR].end())
                return iterR->second;

        }

        //search I type
        auto iterI = link_table[linksI].find(i.func(linksI));

        if(iterI == link_table[linksI].end())
        {
            std::ostringstream out;

            out << std::hex << std::showbase
                << "I_R-type invalid func3 field: "
                << " opcode= " << (i.data.i.opcode&0xff)
                << " rd= " << i.data.i.rd
                << " func3= " << i.data.i.funct3
                << " rs= " << i.data.i.rs1
                << " imm= " << i.data.i.imm11_0;
            throw std::runtime_error(out.str());
        }

        return iterI->second;
    }

private:

    union
    {
        formatR r;
        formatI i;
    } data;

#undef OPERATION
}; //R

} // namespace isa
} // namespace selen
#endif // ISA_I_R_H
