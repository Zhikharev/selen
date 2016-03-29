#ifndef REG123456789SELEN
#define REG123456789SELEN
/*
 * registers definitions
 */

#include <cassert>
#include <cstring>
#include "memory.h"
#include "trace.h"

namespace selen
{

typedef word_t reg_t;
typedef std::size_t reg_id_t;

enum : reg_id_t
{
    R_ZERO,
    R_RA,
    R_SP, R_GP,
    R_TP, R_T0, R_T1, R_T2,
    R_S0, R_S1,
    R_A0, R_A1, R_A2, R_A3, R_A4, R_A5, R_A6, R_A7,
    R_S2, R_S3, R_S4, R_S5, R_S6, R_S7, R_S8, R_S9, R_S10, R_S11,
    R_T3, R_T4, R_T5, R_T6,

    //boundary
    R_LAST,
    R_FIRST = R_ZERO

};

constexpr reg_id_t NUM_REGISTERS = R_LAST;

class Regfile
{
public:

  template<class T>
  void write(const reg_id_t num, const T value)
  {
      assert(num >= 0 && num < selen::NUM_REGISTERS);

      if(!zero_reg || num != 0)
          data[num] = value;
  }

  template<class T>
  T read(const reg_id_t num) const
  {
      assert(num >= 0 && num < selen::NUM_REGISTERS);

      return data[num];
  }

  void clear()
  {
      ::memset(data, 0x0, sizeof(data));
  }

private:
  bool zero_reg = {true};

  reg_t data[NUM_REGISTERS] = {0};
};

//Register names handling

//throw if id > R_LAST
std::string regid2name(const reg_id_t id);

//return R_LAST if there is no register with name
//upper and low case are equal
reg_id_t name2regid(const std::string &name);

const std::vector<std::string>& get_reg_names();

class RegRecord : public TraceRecord
{
public:

    enum
    {
        T_READ = 0,
        T_WRITE
    };

    RegRecord(const int type,
              const reg_id_t id,
              const reg_t value) :
        type(type), id(id),
        value(value)
    {
    }

    std::string to_string() const override
    {
        return Formatter() << "register " << std::setw(5) << ((type == T_READ) ? "READ" : "WRITE" )
                           << "; id " << std::dec << id << " -> " << regid2name(id)
                           << "; value  " << std::showbase << std::hex << std::setw(16) << value;
    }

private:
    int type;
    reg_id_t id;
    reg_t value;
};


} //namespace selen
#endif //REG123456789SELEN
