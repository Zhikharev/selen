#ifndef SIMULATOR123456789SELEN
#define SIMULATOR123456789SELEN

#include <cassert>
#include <string>
#include "state.h"
#include "isa/definitions.h"

namespace selen
{
//Simulator configuration
struct Config
{
    //memory size (bytes)
    std::size_t mem_size = {1024};
    
    //entry program counter value
    addr_t pc = {0};
    //enable tracing
    bool trace = {true};

    //num steps
    size_t steps = {0};

    //endian
    memory_t::ENDIAN endianness = {memory_t::LE};
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

class Simulator
{
public:
    Simulator()
    {
    }

    Simulator(Config &conf)
    {
        state.clear();
        set_config(conf);
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
    bool load(memory_t &image, bool allow_resize = true, addr_t load_offset = 0);


    //run simulator
    std::size_t step(size_t num_steps);
    
    //dump registers and memory to the stream
    void dump_registers(std::ostream& out) const;
    void dump_memory(std::ostream& out) const;

    //set config (this will not reset state)
    void set_config(const Config& econfig);
    const Config &get_config() const;

    void enable_tracing(bool enable = true);

    const Status &get_status() const;

    addr_t get_program_counter() const;
    void set_program_counter(addr_t new_pc);

    const State &get_state() const;

private:
    void cycle(const size_t num_steps);
    instruction_t fetch() const;
    
    State  state;
    Config config;
    Status status;
};

//Printing functions

//base field widht for entries at logs
#define fmtwidht 30

std::ostream &operator<<(std::ostream& os, const Status& st);
std::ostream &operator<<(std::ostream& os, const Config& cfg);
} //namespace selen
#endif //SIMULATOR123456789SELEN
