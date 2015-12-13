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
    unit_t read(const addr_t pos)
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
      if(endianness == LE)
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

        if(endianness == LE)
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

    bool is_little_endian()
    {
        return (endianness == LE);
    }

    void dump(std::ostream& out)
    {
        out << std::showbase << std::hex;
        out << "endianness: " << ((is_little_endian())? "LE" : "BE" ) << std::endl;
        std::string separator(" | ");

        out << std::hex << std::showbase;

        size_t avaib_size = std::floor(size () /WORD_SIZE) * WORD_SIZE;

        for (std::size_t i = 0; i < avaib_size; i = i + WORD_SIZE)
            out << std::setw(10) << i
                << separator
                << read<word_t>(i)
                << std::endl;
    }

private:
    ENDIAN endianness = {LE};
}; //memory


} //namespace selen
#endif //MEM123456789SELEN
