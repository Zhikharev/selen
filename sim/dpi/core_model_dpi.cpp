#include <iostream>
#include <cassert>

#include "core_model_dpi.h"

//libisa
#include "../isa/definitions.h"

struct Config
{
    size_t mem_size = {1024};
    selen::addr_t start_pc = {0};
    bool allow_resize = {false};
    int endianness = {selen::memory_t::LE};
};

class Model
{
public:
    Model() :
        trace("CoreTrace1.txt")
    {
        core.init(&memory);
        core.set_trace(&trace);
    }

    ~Model()
    {
        std::ofstream stream("MemoryDump.txt");
        memory.dump(stream, memory.size());
    }

    void reset(const Config& ecfg)
    {
        cfg = ecfg;
        core.reset();
        memory.resize(cfg.mem_size);
        core.set_pc(cfg.start_pc);
        memory.set_endian((cfg.endianness == 0) ?
                          selen::memory_t::LE :
                          selen::memory_t::BE);
    }

    //all following functions throw

    int set_mem(unsigned int addr, unsigned int data)
    {
        if(addr >= memory.size() &&
           cfg.allow_resize)
        {
            memory.resize(addr + 1);
            // else write will throw
        }

        core.write_mem(addr, data);
        return RC_SUCCESS;
    }

    int get_mem(unsigned int addr, unsigned int *data)
    {
        unsigned int destination = core.read_mem<unsigned int>(addr);
        *data = destination;
        return RC_SUCCESS;
    }

    int get_reg(int reg_id, unsigned int *data)
    {
        assert(reg_id >= 0 && reg_id < (int)selen::NUM_REGISTERS);
        *data = core.get_reg<selen::word_t>(reg_id);

        return RC_SUCCESS;
    }

    int set_reg(int reg_id, unsigned int data)
    {
        assert(reg_id >= 0 && reg_id < (int)selen::NUM_REGISTERS);
        core.set_reg(reg_id, data);

        return RC_SUCCESS;
    }

    int get_pc(unsigned int *data)
    {
        *data = core.get_pc();
        return RC_SUCCESS;
    }

    int set_pc(unsigned int data)
    {
        core.set_pc(data);
        return RC_SUCCESS;
    }

    int step()
    {
        core.step();

        return RC_SUCCESS;
    }

private:
    selen::Core core;

    selen::Trace trace;
    selen::memory_t memory;
    Config cfg;
};

bool verbose(false);
static Model model;

//NO exceptions at C code
#define FUNC_BEGIN \
    try

#define FUNC_END \
    catch(std::exception& e) \
    { \
        if(verbose)\
            std::cout << "[ISA SIM ERROR] " \
                      << e.what() << std::endl;\
        return RC_FAIL; \
    }

extern "C"
{
int init(s_model_params *params)
FUNC_BEGIN
{
    assert(params != nullptr);

    Config cfg;
    cfg.mem_size = params->mem_size;
    cfg.start_pc = params->pc_start;
    cfg.allow_resize = (params->mem_resize != 0);
    cfg.endianness = params->endianness;
    verbose = (params->verbose != 0);

    model.reset(cfg);

    return RC_SUCCESS;
}

FUNC_END

int set_mem(unsigned int addr, unsigned int data)
FUNC_BEGIN
{
    return model.set_mem(addr, data);
}
FUNC_END

int get_mem(unsigned int addr, unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);
    return model.get_mem(addr, data);
}
FUNC_END

int get_reg(int reg_id, unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);
    return model.get_reg(reg_id, data);
}
FUNC_END

int set_reg(int reg_id, unsigned int data)
FUNC_BEGIN
{
    return model.set_reg(reg_id, data);
}
FUNC_END

int get_pc(unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);
    return model.get_pc(data);
}
FUNC_END

int set_pc(unsigned int data)
FUNC_BEGIN
{
    return model.set_pc(data);
}
FUNC_END

int step()
FUNC_BEGIN
{
    return model.step();
}
FUNC_END

} //extern "C"
