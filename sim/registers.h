#ifndef REG123456789SELEN
#define REG123456789SELEN
/*
 * registers definitions
 */

#include <cassert>
#include "memory.h"

namespace selen
{
//register type
union reg_t
{
    //two complement
    word_t s = {0};

    //raw binary
    sword_t u;

    //parts
    hword_t hw[2];
    byte_t  b[4];
};

static_assert(sizeof(reg_t) == sizeof(word_t), "Compiler unable to fit register type");

//register id type
typedef   std::size_t     reg_id_t;

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

    //bounder, not real register
    R_LAST
};

constexpr std::size_t NUM_REGISTERS = R_LAST;


std::string get_regname(const reg_id_t id);

} //namespace selen
#endif //REG123456789SELEN
