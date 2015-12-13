#ifndef ISA_HANDLERS_H
#define ISA_HANDLERS_H

/*
 * Instructio handler
 *  perform instruction on the state / disassemle
 */
#include <sstream>
#include <cassert>
#include "definitions.h"

namespace selen
{
namespace isa
{

//Base class
class handler_t
{
public:
    handler_t(){}
    virtual ~handler_t(){}

    virtual void perform(State&, instruction_t) const = 0;
    virtual std::string disasemble(instruction_t) const = 0;
};

template<class IT>
/*
 *  IT - instruction type class
 *
 *  Concept:
 *
 * class IT
 * {
 *    //  Instruction format
 *    struct ... format_t
 *
 *    //Constructor
 *    IT(format_t l)
 *
 *    //perform on the state
 *    void perform(State& st)
 *
 *    //dump to stream mnemonic + operands
 *    void print(std::ostream& s);
 * }
 */
class Handler : public handler_t
{
    void perform(State& st, instruction_t instr) const
    {
        IT i = decode(instr);
        return i.perform(st);
    }

    std::string disasemble(instruction_t instr) const
    {
        IT i = decode(instr);

        static std::ostringstream out;
        out.str("");

        i.print(out);

        return out.str();
    }

private:
    IT decode(instruction_t instr) const
    {
        typedef typename IT::format_t format_t;
        static_assert( sizeof(format_t) == sizeof(instruction_t),
                "decoded type must fit to instruction_t");

        union
        {
            instruction_t i;
            format_t r;
        } caster = {instr};

        assert(caster.r.opcode == IT::TARGET);

        return IT(caster.r);
    }
}; //Handler

} //namespace isa
} //namespace selen
#endif // ISA_HANDLERS_H
