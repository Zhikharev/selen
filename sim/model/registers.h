#ifndef REG123456789SELEN
#define REG123456789SELEN

#include <cassert>
#include <cstring>
#include <vector>
#include <string>
#include <algorithm>

#include "defines.h"

/*
     general-purpose registers (XPRs)
     // floating-point registers (FPRs)
     privileged control registers (PCRs)
*/
namespace selen
{

typedef size_t reg_id_t;

template<class Traits>
class Regfile
{
public:
  typedef typename Traits::value_t value_t;

  enum
  {
      size = Traits::size
  };

  template<class V>
  void write(const reg_id_t num, const V value)
  {
      assert(num >= 0 && num < size);

      if(num != Traits::zero_reg)
          data[num] = value;
  }

  template<class V>
  V read(const reg_id_t num) const
  {
      assert(num >= 0 && num < size);

      return data[num];
  }

  void clear()
  {
      ::memset(data, 0x0, sizeof(data));
  }

  static
  std::string id2name(const reg_id_t id)
  {
      if(id >= size)
          throw std::invalid_argument("bad register id");

      return Traits::names[id];
  }

  static
  reg_id_t name2id(const std::string &name)
  {
      //upper and low case are equal
      std::string _name;
      std::transform(name.begin(), name.end(),
                     std::back_inserter(_name), ::tolower);

      for (reg_id_t i = 0; i < size; i++)
      {
          if(_name == Traits::names[i])
              return i;
      }

      return size;
  }

  static
  const std::vector<std::string>& get_reg_names()
  {
      return Traits::names;
  }

private:
  value_t data[size] = {0};
};

//general-purpose registers (XPRs)
struct XPRTraits
{
    typedef word_t value_t;

    static constexpr size_t size = {32};
    static constexpr int zero_reg = {0};

    static const std::vector<std::string> names;
};

typedef Regfile<XPRTraits> XPR;

} //namespace selen
#endif //REG123456789SELEN
