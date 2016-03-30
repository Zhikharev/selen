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

class MemRecord : public TraceRecord
{
public:

    enum
    {
        T_READ = 0,
        T_WRITE
    };

    MemRecord(const int type,
              const addr_t addr,
              const size_t size,
              uintmax_t value) :
        type(type), addr(addr),
        size(size), value(value)
    {
    }

    std::string to_string() const override
    {
        return Formatter() << "memory " << std::setw(5) << ((type == T_READ) ? "READ" : "WRITE" )
                           << "; size " << std::dec << size << " bytes"
                           << "; addr " << hex(addr)
                           << "; value " << hex(value, size * 2);
    }

private:
    int type;
    addr_t addr;
    size_t size;
    uintmax_t value;
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
            trace->write(MemRecord{MemRecord::T_READ, addr,
                                  sizeof(unit_t), static_cast<uintmax_t>(value)});

        return value;
    }

    template<typename unit_t>
    void write_mem(const addr_t addr, unit_t value)
    {
        assert(mem != nullptr);

        if(trace != nullptr)
            trace->write(MemRecord{MemRecord::T_WRITE, addr,
                                  sizeof(unit_t), static_cast<uintmax_t>(value)});

        mem->write<unit_t>(addr, value);
    }

    template<typename unit_t>
    unit_t get_reg(const reg_id_t id) const
    {
        unit_t value = state.reg.read<unit_t>(id);
        if(trace != nullptr)
            trace->write(RegRecord{id, static_cast<reg_t>(value)});
        return value;
    }

    template<typename unit_t>
    void set_reg(const reg_id_t id, const unit_t value)
    {
        if(trace != nullptr)
            trace->write(RegRecord{id, static_cast<reg_t>(value),
                                   state.reg.read<reg_t>(id)});

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

    memory_t* mem = {nullptr};
    Trace* trace = {nullptr};
};

} // namespace selen
#endif
