#ifndef STATE123456789SELEN
#define STATE123456789SELEN

#include "memory.h"
#include "registers.h"

#include "trace.h"
#include "../utils.h"

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

    void dump(std::ostream& out) const;
};

class Core
{
public:
    Core()
    {
    }

    Core(const Core&) = delete;
    Core& operator=(const Core&) = delete;

    void reset()
    {
        state.clear();
    }

    //nullptr will disable tracing
    void set_trace(Trace* etrace)
    {
        trace = etrace;
    }

    template<typename unit_t>
    unit_t read_mem(const addr_t addr) const
    {
        assert(mem != nullptr);

        unit_t value = mem->read<unit_t>(addr);

        if(trace != nullptr)
            trace->write(trace::RMemory{trace::T_READ, addr,
                                  sizeof(unit_t), static_cast<uintmax_t>(value)});

        return value;
    }

    template<typename unit_t>
    void write_mem(const addr_t addr, unit_t value)
    {
        assert(mem != nullptr);

        if(trace != nullptr)
            trace->write(trace::RMemory{trace::T_WRITE, addr,
                                  sizeof(unit_t), static_cast<uintmax_t>(value)});

        mem->write<unit_t>(addr, value);
    }

    template<typename unit_t>
    unit_t get_reg(const reg_id_t id) const
    {
        unit_t value = state.reg.read<unit_t>(id);
        if(trace != nullptr)
            trace->write(trace::RRegister{id, static_cast<reg_t>(value)});
        return value;
    }

    template<typename unit_t>
    void set_reg(const reg_id_t id, const unit_t value)
    {
        if(trace != nullptr)
            trace->write(trace::RRegister{id, static_cast<reg_t>(value),
                                   state.reg.read<reg_t>(id)});

        state.reg.write<unit_t>(id, value);
    }

    addr_t get_pc() const;
    void set_pc(const addr_t pc);
    void increment_pc(const sword_t value = sword_t(selen::WORD_SIZE));

    //step next instruction, throw
    void step();

    const CoreState& get_state() const;
    void init(memory_t* region);

private:
    selen::word_t fetch() const;

    CoreState state;

    memory_t* mem = {nullptr};
    Trace* trace = {nullptr};
};

} // namespace selen
#endif
