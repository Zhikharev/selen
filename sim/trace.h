#ifndef TRACE123456789SELEN
#define TRACE123456789SELEN

#include <fstream>
#include "utils.h"
#include "memory.h"

namespace selen
{

class TraceRecord
{
public:
    TraceRecord()
    {
    }

    virtual ~TraceRecord()
    {}

    virtual std::string to_string() const = 0;
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

    virtual std::string to_string() const
    {
        return Formatter() << "memory " << std::setw(5) << ((type == T_READ) ? "READ" : "WRITE" )
                           << "; size " << std::dec << size << " bytes"
                           << "; addr " << std::showbase << std::hex << std::setw(16) << addr
                           << "; value " << value;
    }

private:
    int type;
    addr_t addr;
    size_t size;
    uintmax_t value;
};

class Trace
{
public:
    Trace(const std::string& filename)
    {
        stream.open(filename);

        if (!stream.is_open ())
            throw std::runtime_error (Formatter()
                                      << "unable open file for trace " << filename);

        stream.exceptions (std::ostream::failbit | std::ostream::badbit);
    }

    ~Trace()
    {
        stream.flush();
        stream.close();
    }

    void write(TraceRecord&& record)
    {
        stream << std::setw(10) << recordnumber++ << ":\t"
               << record.to_string() << std::endl;
    }

private:
    size_t recordnumber = {0};
    std::ofstream stream;
};

} //namespace selen
#endif // TRACE123456789SELEN
