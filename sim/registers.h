#ifndef REG123456789SELEN
#define REG123456789SELEN
/*
 * registers definitions
 */

#include <cassert>
#include <cstring>
#include "memory.h"

namespace selen
{

typedef word_t reg_t;
typedef std::size_t reg_id_t;

enum : reg_id_t
{
    //zero register
    R_ZERO,

    //assembler temporary
    R_AT,

    //valuxus
    R_V0, R_V1,

    //arguments
    R_A0, R_A1, R_A2, R_A3,

    //temporaries
    R_T0, R_T1, R_T2, R_T3, R_T4,
    R_T5, R_T6, R_T7,

    //saved valuxs
    R_S0, R_S1, R_S2, R_S3,
    R_S4, R_S5, R_S6, R_S7,

    //temporaries
    R_T8, R_T9,

    //interrupts
    R_K0, R_K1,

    //global pointer
    R_GP,

    //stack pointer
    R_SP,

    //frame pointer, saved value
    R_FP,
    R_S8 = R_FP,

    //return addres
    R_RA,

    //boundary, not real registers
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

} //namespace selen
#endif //REG123456789SELEN
