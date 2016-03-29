#ifndef TRACE123456789SELEN
#define TRACE123456789SELEN

#include <fstream>
#include "utils.h"

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
