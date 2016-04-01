#ifndef MEM123456789SELEN
#define MEM123456789SELEN

#include <type_traits>
#include <stdexcept>
#include <climits>
#include <vector>
#include <cassert>
#include <cmath>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <functional>
#include <cstring>

#include "defines.h"
#include "../utils.h"

#include <memory>

namespace selen
{

//physical memory page
class page_t
{
public:
    enum : size_t
    {
        ADDRESS_SIZE = 12, //4 Kb
        BYTE_SIZE = (1 << ADDRESS_SIZE)
    };

public:
    page_t()
    {
    }

    inline
    byte_t read(const addr_t offset) const
    {
        assert(offset < BYTE_SIZE);
        return (data) ? data.get()[offset] : 0x00;
    }

    inline
    void write(const byte_t value,
               const addr_t offset)
    {
        assert(offset < BYTE_SIZE);

        if(!data)
        {
            if(value == 0x00)
                return;

            data.reset(new byte_t[BYTE_SIZE],
                std::default_delete<byte_t[]>());

            ::memset(data.get(), 0, BYTE_SIZE);
        }

        data.get()[offset] = value;
    }

private:
    //std::vector resize, copy and delete Pages, need hold pointer
    std::shared_ptr<byte_t> data;
};

//physical memory region
class region_t
{
public:
    region_t(const addr_t size)
    {
        resize(size);
    }

    inline
    byte_t read(const addr_t address) const
    {
        assert(address <= max_address);

        const addr_t index = get_index(address);
        const addr_t offset = get_offset(address);

        return pages[index].read(offset);
    }

    inline
    void write(const addr_t address, const byte_t value)
    {
        assert(address <= max_address);

        const addr_t index = get_index(address);
        const addr_t offset = get_offset(address);

        pages[index].write(value, offset);
    }

    inline
    void resize(const size_t new_size)
    {
        size_t max_index = get_index(new_size);

        //page align
        if(get_offset(new_size) > 0)
            max_index++;

        max_address = max_index * page_t::BYTE_SIZE;

        pages.resize(max_index);
    }

    inline
    size_t size() const
    {
        return max_address;
    }

private:
    enum : addr_t
    {
        MASK_INDEX = addr_t((~0) << page_t::ADDRESS_SIZE),
        MASK_OFFSET = ~MASK_INDEX
    };

    inline static
    addr_t get_index(const addr_t address)
    {
        return (MASK_INDEX & address) >> page_t::ADDRESS_SIZE;
    }

    inline static
    addr_t get_offset(const addr_t address)
    {
        return MASK_OFFSET & address;
    }

private:
    std::vector<page_t> pages;
    size_t max_address;
};

class memory_t
{
public:
    memory_t (const size_t size = 0) :
        address_space(size)
    {
    }

    template< typename unit_t>
    unit_t read(const addr_t addr) const
    {
      static_assert(std::is_integral<unit_t>::value ,"unit_t must be integer");

      if(address_space.size() + sizeof(unit_t) < addr)
          throw std::out_of_range(Formatter()
                                  << "memory read: address refers to position out of memory: "
                                  << std::hex << std::showbase << addr
                                  << ", avaible memory size: " << address_space.size());

      unit_t result = 0;
      const size_t max_index = sizeof(unit_t) - 1;

      for(size_t i = 0; i <= max_index; i++ )
      {
            result = result << CHAR_BIT;

            const size_t pos = (endianness == LE) ? (max_index - i) : i;

            byte_t b = address_space.read(addr + pos);
            result = (result | static_cast<unit_t>(b & 0xff)) ;
      }

      return result;
    }

    template<typename unit_t>
    void write(const addr_t addr, unit_t value)
    {
        static_assert(std::is_integral<unit_t>::value ,"unit_t must be integer");

        if(address_space.size() + sizeof(unit_t) < addr)
            throw std::out_of_range(Formatter()
                                    << "write address refers to position out of memory: "
                                    << std::hex << std::showbase
                                    << addr << ", avaible memory size: " << address_space.size());

        union
        {
            byte_t b[sizeof(unit_t)];
            unit_t t;
        } result;

        result.t = value;

        const size_t max_index = sizeof(unit_t) - 1;

        for (size_t i = 0; i <= max_index; i++)
        {
            //b[] holds little endian value
            const size_t pos = (endianness == LE) ? i : (max_index - i);
            address_space.write(addr + i, result.b[pos]);
        }

        return;
    }

    inline
    size_t size() const
    {
        return address_space.size();
    }

    inline
    void resize(const size_t size)
    {
        address_space.resize(size);
    }

    void load(const byte_t * data,
              const size_t size,
              const addr_t dest = 0)
    {
        assert(data != nullptr);

        if(dest > address_space.size())
            throw std::runtime_error(Formatter()
                                     << "Try to load data to invalid address "
                                     << std::showbase << std::hex << dest
                                     << ", max valid address " << address_space.size());

        if(dest + size > address_space.size())
            throw std::runtime_error(Formatter()
                                     << "Not enought memory to load " << size << " bytes "
                                     << "to address " << std::showbase << std::hex << dest
                                     << ", max valid address " << address_space.size());

        if(size == 0)
            return;

        //TODO: profile, implement fast page loading
        size_t counter = 0;
        while(counter < size)
        {
            const byte_t token = *(data + counter);
            const addr_t target = dest + counter;

            address_space.write(target, token);
            counter++;
        }
    }

    enum ENDIAN : size_t
    {
        LE,
        BE
    };

    void set_endian(const size_t value = LE)
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
    void dump(std::ostream& out,
              const size_t num,
              const size_t start_addr = 0,
              dumper_t dmp = dumper_t()) const
    {
        typedef typename dumper_t::token_t token_t;

        size_t avaib_size = std::floor(address_space.size() /sizeof(token_t)) * sizeof(token_t);
        if(start_addr > avaib_size)
            throw std::runtime_error(Formatter()
                                     << "try access to memory at invalid address "
                                     << std::hex << std::showbase << start_addr
                                     << ", max valid address: " << avaib_size);

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
    size_t endianness = {LE};
    region_t address_space;
}; //memory


} //namespace selen
#endif //MEM123456789SELEN
