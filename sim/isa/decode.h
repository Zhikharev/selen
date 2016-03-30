#ifndef INSTRUCTION_H
#define INSTRUCTION_H

#include "definitions.h"
#include "../trace.h"

namespace selen
{

namespace isa
{

//opcodes
enum : word_t
{
    OP_R     = 0b0110011,
    OP_I_R   = 0b0010011,
    OP_LUI   = 0b0110111,
    OP_AUIPC = 0b0010111,
    OP_SB    = 0b1100011,
    OP_JAL   = 0b1101111,
    OP_JALR  = 0b1100111,
    OP_LOAD  = 0b0000011,
    OP_STORE = 0b0100011,
};

class instruction_t
{
public:
    instruction_t() = default;
    instruction_t(word_t bits) :
        bits(bits)
    {
    }

    operator word_t&()
    {
        return bits;
    }

    operator word_t() const
    {
        return bits;
    }

    word_t inline opcode() const
    {
        return x(0, 7);
    }

public:
    //immediate
    sword_t inline immI() const
    {
        return sword_t(bits) >> 20;
    }

    sword_t inline immS() const
    {
        return (xs(25, 7) << 5) + x(7, 5);
    }

    sword_t inline immSB() const
    {
        return (xs(63, 1) << 12) + (x(7,1) << 11) + (x(25,6) << 5) + (x(8, 4) << 1);
    }

    sword_t inline immU() const
    {
        return sword_t(bits) >> 12 << 12;
    }

    sword_t inline immUJ() const
    {
        return (xs(63, 1) << 20) + (x(12, 8) << 12) + (x(20, 1) << 11) + (x(21, 10) << 1);
    }

public:
    //operands
    word_t inline rd() const
    {
        return x(7, 5);
    }

    word_t inline rs1() const
    {
        return x(15, 5);
    }

    word_t inline rs2() const
    {
        return x(20, 5);
    }

    word_t inline rs3() const
    {
        return x(27, 5);
    }

    word_t inline rm() const
    {
        return x(12, 3);
    }

private:
    //extract
    word_t inline x(const size_t begin,
                    const size_t len) const
    {
        return (bits >> begin) & ((word_t(1) << len) - 1);
    }
    //extract & signed extension
    word_t inline xs(const size_t begin,
                     const size_t len) const
    {
        return sword_t(bits) << (BITS_SIZE - begin - len) >> (BITS_SIZE - len);
    }

private:
    static constexpr const size_t BITS_SIZE = selen::WORD_SIZE * CHAR_BIT;
    word_t bits = {0};
};

//instruction description
struct descriptor_t
{
    //match/search
    const word_t mask;
    const word_t pattern;

    bool inline operator == (const instruction_t instruction) const
    {
        return pattern == (instruction & mask);
    }

    //disassembler
    const std::string mnemonic;
    const word_t format;

    //perform
#define ISA_OPERATION (selen::Core& core, const selen::isa::instruction_t i)
    const std::function<void ISA_OPERATION> operation;
};

typedef const descriptor_t* descriptor_ptr_t;

std::string print_instruction(const std::string& mnemonic,
                              const word_t format,
                              const instruction_t i);

//decoded and ready to perform instruction
struct fetch_t
{
    void operator() (selen::Core& core) const
    {
        description->operation(core, instruction);
    }

    std::string disasemble() const
    {
        return print_instruction(description->mnemonic, description->format, instruction);
    }

    instruction_t instruction;
    descriptor_ptr_t description;
};

} //namespace isa


class InsFetchRecord : public TraceRecord
{
public:
    InsFetchRecord(const addr_t pc, const isa::fetch_t& f) :
        pc(pc),
        data(f)
    {
    }


    std::string to_string() const override
    {
        const word_t instr = data.instruction;
        return Formatter() << "\t\t||-- " << hex(pc)
                           << "\t " << hex(instr)
                           << "\t" <<  data.disasemble();
    }

private:
    addr_t pc;
    const isa::fetch_t& data;
};


} //namespace selen
#endif // INSTRUCTION_H
