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
    Model()
    {
    }

    void reset(const Config& ecfg)
    {
        cfg = ecfg;
        state.clear();
        state.mem.resize(cfg.mem_size);
        state.pc = cfg.start_pc;
        state.mem.set_endian((cfg.endianness == 0) ?
                              selen::memory_t::LE :
                              selen::memory_t::BE);
    }

    //all following functions throw

    int set_mem(unsigned int addr, unsigned int data)
    {
        if(addr >= state.mem.size() &&
           cfg.allow_resize)
        {
            state.mem.resize(addr + 1);
            // else write will throw
        }

        state.mem.write(addr, data);
        return RC_SUCCESS;
    }

    int get_mem(unsigned int addr, unsigned int *data)
    {
        unsigned int destination = state.mem.read<unsigned int>(addr);
        *data = destination;
        return RC_SUCCESS;
    }

    int get_reg(int reg_id, unsigned int *data)
    {
        assert(reg_id >= 0 && reg_id < (int)selen::NUM_REGISTERS);
        *data = state.reg[reg_id].u;

        return RC_SUCCESS;
    }

    int set_reg(int reg_id, unsigned int data)
    {
        assert(reg_id >= 0 && reg_id < (int)selen::NUM_REGISTERS);
        state.reg[reg_id].u = data;

        return RC_SUCCESS;
    }

    int get_pc(unsigned int *data)
    {
        *data = state.pc;
        return RC_SUCCESS;
    }

    int set_pc(unsigned int data)
    {
        state.pc = data;
        return RC_SUCCESS;
    }


    int step()
    {
        selen::instruction_t instr = selen::isa::fetch(state);
        selen::isa::perform(state, instr);

        return RC_SUCCESS;
    }

private:
    selen::State state;
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
    cfg.allow_resize = true;
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
