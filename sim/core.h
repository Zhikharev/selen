#ifndef STATE123456789SELEN
#define STATE123456789SELEN

#include "registers.h"
#include "trace.h"

namespace selen
{

struct CoreState
{
    Regfile reg;
    addr_t pc = {0};

    void clear()
    {
        pc = 0;
        reg.clear();
    }
};

class Core
{
public:
    Core() :
        //TODO:: it is experimental tracing, rework
        trace("CoreTrace.txt")
    {
    }

    Core(const Core&) = delete;
    Core& operator=(const Core&) = delete;

    void reset()
    {
        state.clear();
    }

    template<typename unit_t>
    unit_t read_mem(const addr_t addr) const
    {
        assert(mem != nullptr);

        unit_t value = mem->read<unit_t>(addr);

        trace.write(MemRecord{MemRecord::T_READ, addr,
                               sizeof(unit_t), static_cast<uintmax_t>(value)});

        return value;
    }

    template<typename unit_t>
    void write_mem(const addr_t addr, unit_t value)
    {
        assert(mem != nullptr);

        trace.write(MemRecord{MemRecord::T_WRITE, addr,
                               sizeof(unit_t), static_cast<uintmax_t>(value)});

        mem->write<unit_t>(addr, value);
    }

    template<typename unit_t>
    unit_t get_reg(const reg_id_t id) const
    {
        return state.reg.read<unit_t>(id);
    }

    template<typename unit_t>
    void set_reg(const reg_id_t id, const unit_t value)
    {
        state.reg.write<unit_t>(id, value);
    }

    addr_t inline get_pc() const
    {
        return state.pc;
    }

    void set_pc(const addr_t pc)
    {
        state.pc = pc;
    }

    void increment_pc(const sword_t value = sword_t(selen::WORD_SIZE))
    {
        state.pc += value;
    }

    //step next instruction, throw
    void step();

    const CoreState& get_state() const
    {
        return state;
    }

    void init(memory_t* region)
    {
        mem = region;
    }

    selen::word_t fetch() const
    {
        assert(mem != nullptr);

        const addr_t pc = get_pc();
        if(pc > mem->size() + selen::WORD_SIZE)
            throw std::runtime_error("PC refers to invalid address: "
                                     "out of memory range");

        return read_mem<word_t>(pc);
    }

private:
    CoreState state;
    mutable Trace trace;

    memory_t* mem = {nullptr};
};

} // namespace selen
#endif
