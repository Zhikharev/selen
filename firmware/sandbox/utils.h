#ifndef UTILS_H
#define UTILS_H

typedef __SIZE_TYPE__ size_t;
typedef __UINT8_TYPE__ uint8_t;
typedef __UINT32_TYPE__ uint32_t;

/*extract len bits*/
static inline
uint32_t extract(const uint32_t value, const size_t begin,
                 const size_t len)
{
    return (value >> begin) & ((1 << len) - 1);
}

/*put bit field to integer*/
static inline
uint32_t deposit(uint32_t value, int begin, int len,
                 uint32_t fieldval)
{
    uint32_t mask = (~0U >> (32 - len)) << begin;
    return (value & ~mask) | ((fieldval << begin) & mask);
}

#define BIT_MASK(n) ((uint32_t)1 << n)

static
void jump_to(volatile void* label)
{
    asm("jalr x0, %0\n"
        "nop\n"
        "nop\n"
        "nop\n"
        : : "r" (label) );
}

#define assert(pred) if(!(pred)) asm ("j _exit\n")

#endif // UTILS_H
