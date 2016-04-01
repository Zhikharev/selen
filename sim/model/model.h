#ifndef SIMULATOR123456789SELEN
#define SIMULATOR123456789SELEN

#include <cassert>
#include <string>

#include "riscv.h"

namespace selen
{
//Simulator configuration
struct Config
{
    //memory size (bytes)
    std::size_t mem_size = {1024};
    bool allow_resize = {true};
    
    //entry program counter value
    addr_t pc = {0};

    bool trace = {true};
    trace::Config trace_config;

    //num steps
    size_t steps = {0};

    //model run as dpi library
    bool isDPI = false;

    size_t verbosity = 1;
    //endian
    size_t endianness = {memory_t::LE};
};

//Simulator dynamic data
struct Status
{
    int return_code = {EXIT_SUCCESS};
    bool was_error = {false};
    std::string error_description;

    bool image_loaded = {false};
    bool in_progress = {false};

    //steps made at last Simulator::step call
    size_t steps_made_last = {0};
    //steps made from begin
    size_t steps_made_from_begin = {0};
};

class Model
{
public:
    Model()
    {
        core.init(&memory);
    }

    /**
     * @brief load image to simulator memory
     *   Simulator memory NOT cleared before load
     *   if image empty and load_offset > current memory size then memory resized to load_offset
     *
     * @param image data to load
     * @param allow_resize - if true memory will be resized if there is no space to image with offset,
     *                       value of config.mem_size ignored
     * @param load_offset - physical address position image should start with
     * @return false if allow_resize is "false" but there is no space to load, otherwise true
     */
    bool load(const std::vector<byte_t>& image, bool allow_resize = true, addr_t load_offset = 0);

    //run simulator
    std::size_t step(const size_t num_steps);
    
    //dump registers and memory to the stream
    void dump_state(std::ostream& out) const;

    //set config (this will not reset state)
    void set_config(const Config& econfig);
    const Config &get_config() const;

    void enable_tracing(const bool enable = true);

    const Status &get_status() const;

    addr_t get_program_counter() const;
    void set_program_counter(const addr_t value);

    const selen::CoreState& get_core_state() const;
    const memory_t &get_memory() const;

    template<class unit_t>
    void write_mem(const addr_t addr, const unit_t value)
    {
        if(addr >= memory.size() &&
            config.allow_resize)
        {
            memory.resize(addr + 1);
            //else write will try
        }

        core.write_mem(addr, value);
    }

    template<class unit_t>
    unit_t read_mem(const addr_t addr)
    {
        return core.read_mem<unit_t>(addr);
    }

    template<class unit_t>
    unit_t get_reg(const reg_id_t reg_id)
    {
        return core.get_reg<unit_t>(reg_id);
    }

    template<class unit_t>
    void set_reg(const reg_id_t reg_id, const unit_t value)
    {
        core.set_reg(reg_id, value);
    }

    template<class Stringable>
    void write_to_trace(const Stringable s)
    {
        trace.write(s);
    }

private:
    void cycle(const size_t num_steps);
    
    //now it is only one core!
    memory_t memory;
    selen::Core core;

    //and only one trace!
    Trace trace;

    Config config;
    Status status;
};

//Printing functions

std::ostream &operator<<(std::ostream& os, const Status& st);
std::ostream &operator<<(std::ostream& os, const Config& cfg);
} //namespace selen
#endif //SIMULATOR123456789SELEN
