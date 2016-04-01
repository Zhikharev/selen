#include <iostream>
#include <cassert>
#include <fstream>
#include <iomanip>

//model lib header
#include "../model/model.h"
#include "core_model_dpi.h"

using namespace std;

size_t verbosity;
static selen::Model model;

//NO exceptions at C code
#define FUNC_BEGIN \
    try

#define FUNC_END \
    catch(std::exception& e) \
    { \
        std::string error = std::string("[ISA SIM ERROR] ") + e.what();\
        if(verbosity != 0)\
            std::cerr << error << std::endl;\
               \
        model.write_to_trace(error);\
        return RC_FAIL; \
    }

static const std::string callPrefix = "[DPI CALL]";

extern "C"
{

int init(s_model_params *params)
FUNC_BEGIN
{
    assert(params != nullptr);

    selen::Config cfg;
    cfg.mem_size = params->mem_size;
    cfg.pc = params->pc_start;
    cfg.allow_resize = (params->mem_resize != 0);
    cfg.endianness = params->endianness;

    //tracing
    cfg.trace_config.toCout = (params->trace_console != 0);
    cfg.trace_config.toFile = (params->trace_file != 0);
    cfg.verbosity = params->verbosity_level;
    cfg.isDPI = true;
    verbosity = cfg.verbosity;

    model.set_config(cfg);

    return RC_SUCCESS;
}
FUNC_END

extern int dump_state(const char* filename)
FUNC_BEGIN
{
    assert(filename != nullptr);

    std::ofstream stream(filename);
    model.dump_state(stream);

    return RC_SUCCESS;
}
FUNC_END

int set_mem(unsigned int addr, unsigned int data)
FUNC_BEGIN
{
    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "set_mem "
            << "addr " << hex(addr)
            << ", data " << hex(data)
            ));

    model.write_mem(addr, data);

    return RC_SUCCESS;
}
FUNC_END

int get_mem(unsigned int addr, unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);

    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "get_mem "
            << "addr " << hex(addr)
            ));

    *data = model.read_mem<unsigned int>(addr);

    return RC_SUCCESS;
}
FUNC_END

int get_reg(int reg_id, unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);

    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "get_reg "
            << "id " << dec << reg_id
            ));

    *data = model.get_reg<unsigned int>(reg_id);
    return RC_SUCCESS;
}
FUNC_END

int set_reg(int reg_id, unsigned int data)
FUNC_BEGIN
{
    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "set_reg "
            << " id " << dec << reg_id
            << ", data " << hex(data)
            ));

    model.set_reg(reg_id, data);
    return RC_SUCCESS;
}
FUNC_END

int get_pc(unsigned int *data)
FUNC_BEGIN
{
    assert(data != nullptr);
    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "get_pc "
            ));

    *data = model.get_program_counter();

    return RC_SUCCESS;
}
FUNC_END

int set_pc(unsigned int data)
FUNC_BEGIN
{
    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "set_pc ("
            << ", data " << hex(data)
            ));

    model.set_program_counter(data);
    return RC_SUCCESS;
}
FUNC_END

int step()
FUNC_BEGIN
{
    model.write_to_trace(std::string(
        Formatter() << std::left << setw(FMT_WIDHT/2) << callPrefix
            << "step "
            ));

    return (model.step(1) != 0) ? RC_SUCCESS : RC_FAIL;
}
FUNC_END

} //extern "C"
