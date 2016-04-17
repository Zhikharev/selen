#ifndef TRACE123456789SELEN
#define TRACE123456789SELEN

#include <fstream>
#include <string>
#include <iostream>

#include "defines.h"
#include "riscv/decode.h"
#include "../utils.h"

namespace selen
{

//trace , trace records
namespace trace
{

struct Config
{
    bool toCout = {true};
    bool toFile = {false};
    std::string filename = {"Trace.txt"};
};

class Trace
{
public:
    Trace()
    {
    }

    Trace(const trace::Config& config)
    {
        reset(config);
    }

    void reset(const trace::Config& econfig)
    {
        if(file.is_open())
            file.close();

        config = econfig;

        if(config.toFile)
        {
            file.open(config.filename);

            if (!file.is_open ())
                throw std::runtime_error (Formatter()
                    << "unable open file for trace " << config.filename);

            file.exceptions (std::ostream::failbit | std::ostream::badbit);
        }
    }

    ~Trace()
    {
        file.flush();
        file.close();
    }

    template<class T>
    void write(const T record)
    {
        out.str("");
        std::string token = record;
        out << std::setw(FMT_WIDHT / 3) << recordnumber++ << ":\t"
            << token << std::flush;

        if(config.toFile)
            file << out.str() << std::endl;

        if(config.toCout)
            std::cout << out.str() << std::endl;
    }

private:
    std::size_t recordnumber = {0};
    std::ostringstream out;

    trace::Config config;
    std::ofstream file;
};

enum
{
    T_READ = 0,
    T_WRITE
};

class RMemory
{
public:
    RMemory(const int type,
        const addr_t addr,
        const size_t size,
        uintmax_t value) :
            type(type), addr(addr),
            size(size), value(value)
    {
    }

    operator std::string() const
    {
        return Formatter() << std::left << std::setw(FMT_WIDHT/2) << "[memory]" << std::setw(5) << ((type == T_READ) ? "READ" : "WRITE" )
                           << "; size " << std::dec << size << " bytes"
                           << "; addr " << hex(addr)
                           << "; value " << hex(value, size * 2);
    }

private:
    int type;
    addr_t addr;
    std::size_t size;
    std::uintmax_t value;
};

class RRegister
{
public:
    //read record
    RRegister(const reg_id_t id,
        const word_t value) :
            type(T_READ), id(id),
            value(value)
    {
    }

    //write record
    RRegister(const reg_id_t id,
        const word_t new_value,
        const word_t old_value) :
            type(T_WRITE), id(id),
            value(new_value),
            diff(new_value - old_value)
    {
    }

    operator std::string() const
    {
        std::ostringstream out;
        out << std::left << std::setw(FMT_WIDHT/2) << "[register]" << std::setw(5) << ((type == T_READ) ? "READ" : "WRITE" )
            << "; id " << std::dec << id << " -> " << selen::XPR::id2name(id)
            << "; value  " << hex(value);

        if(type == T_WRITE)
            out << "; diff " << std::dec << diff
                << " (" << std::showbase << std::hex << diff << ")";

        return out.str();
    }

private:
    int type;
    reg_id_t id;
    word_t value;
    sword_t diff;
};

class RInsFetch
{
public:
    RInsFetch(const addr_t pc, const isa::fetch_t& f) :
        pc(pc),
        data(f)
    {
    }

    operator std::string () const
    {
        const word_t instr = data.instruction;

        std::ostringstream out;
        out << std::left << std::setw(FMT_WIDHT/2) << "[fetch]" << "\t-|-->\t"
            << hex(pc)
            << "\t " << hex(instr)
            << "\t";
        data.disasemble(out);

        return out.str();
    }

private:
    addr_t pc;
    const isa::fetch_t& data;
};

} // namespace trace

typedef trace::Trace Trace;

} //namespace selen
#endif // TRACE123456789SELEN
