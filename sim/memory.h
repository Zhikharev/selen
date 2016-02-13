#ifndef MEM123456789SELEN
#define MEM123456789SELEN
/*
 * memory definitions
 */
#include <type_traits>
#include <stdexcept>
#include <cstdint>
#include <climits>
#include <vector>
#include <cassert>
#include <cmath>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <functional>

namespace selen
{

typedef uint8_t   byte_t;
typedef uint16_t  hword_t;
typedef uint32_t  word_t;

//signed
typedef int8_t   sbyte_t;
typedef int16_t  shword_t;
typedef int32_t  sword_t;


constexpr size_t WORD_SIZE = sizeof(word_t);

//address type
typedef uint32_t  addr_t;

//memory
class memory_t :
        public std::vector<byte_t>
{
public:
    //inherit all constructors
    using std::vector<byte_t>::vector;

    //read/write

    template< typename unit_t>
    unit_t read(const addr_t pos) const
    {
      static_assert(std::is_integral<unit_t>::value ,"unit_t must be integer");
      if((size() + sizeof(unit_t)) < pos)
      {
          std::ostringstream out;
          out << "memory read: address refers to position out of memory: "
              << std::hex << std::showbase << pos << ", avaible memory size: " << size();
          throw std::out_of_range(out.str());
      }

      unit_t result = 0;
      if(endianness != BE)
      {
          const unit_t* tmp =reinterpret_cast<const unit_t*>(this->data()+pos) ;
          result = *tmp;
          return result;
      }

      for(size_t index = 0;index < sizeof(unit_t); index++ )
      {
            result = result << CHAR_BIT;
            byte_t b = this->at(pos+index);
            result = (result|static_cast<unit_t>(b & 0xff)) ;
      }

      return result;
    }

    template<typename unit_t>
    void write(const addr_t pos, unit_t value)
    {
        static_assert(std::is_integral<unit_t>::value ,"unit_t must be integer");
        if((size() + sizeof(unit_t)) < pos)
        {
            std::ostringstream out;
            out << "write address refers to position out of memory: "
                << std::hex << std::showbase << pos << ", avaible memory size: " << size();
            throw std::out_of_range(out.str());
        }

        union
        {
            byte_t b[sizeof(unit_t)];
            unit_t   t;
        } result;

        result.t = value;

        if(endianness != BE)
        {
            for (size_t i = 0;i < sizeof(unit_t); i++)
                this->operator [](pos + i) = result.b[i];
            return;
        }

        for (size_t i = 0;i < sizeof(unit_t); i++)
            this->operator [](pos + i) = result.b[sizeof(unit_t) - i - 1];
    }

    enum ENDIAN
    {
        LE,
        BE
    };

    void set_endian(ENDIAN value = LE)
    {
        endianness = value;
    }

    bool is_little_endian() const
    {
        return (endianness == LE);
    }

    template<class T>
    struct memory_dumper
    {
        typedef T token_t;
        void inline operator()(const T token, std::ostream& out)
        {
            out << token;
        }
    };

    template<class dumper_t = memory_dumper<word_t> >
    void dump(std::ostream& out, size_t num, size_t start_addr = 0, dumper_t dmp = dumper_t()) const
    {
        typedef typename dumper_t::token_t token_t;

        size_t avaib_size = std::floor(size () /sizeof(token_t)) * sizeof(token_t);
        if(start_addr > avaib_size)
        {
            std::ostringstream out;
            out << "try access to memory at invalid address "
                << std::hex << std::showbase << start_addr
                << ", max valid address: " << avaib_size;

            throw std::runtime_error(out.str());
        }

        std::string separator("\t");
        size_t end_addr = std::min(start_addr + num*sizeof(token_t), avaib_size);

        out << std::showbase << std::hex;
        for (std::size_t i = start_addr; i < end_addr; i = i + sizeof(token_t))
        {
            token_t token = this->read<token_t>(i);

            out << std::setw(10) << std::hex  << i
                << separator;

            dmp(token, out);

            out << std::endl;
        }
    }
private:
    ENDIAN endianness = {LE};
}; //memory


} //namespace selen
#endif //MEM123456789SELEN
