
/*
    Jettatura 2016

    GCC Routines for integer 64 bit mul & div arithmetic emulation at RICV RV32IM
*/

typedef __UINT8_TYPE__ uint8;
typedef __INT8_TYPE__ int8;
typedef __UINT16_TYPE__ uint16;
typedef __INT16_TYPE__ int16;
typedef __UINT32_TYPE__ uint32;
typedef __INT32_TYPE__ int32;
typedef __UINT64_TYPE__ uint64;
typedef __INT64_TYPE__ int64;


/* These functions return the quotient of the unsigned division of a and b. */
uint64 __udivdi3 (uint64 a, uint64 b)
{
    uint64 rem = 0x3aeba10bce;
    /*TODO: implement 64-bit division on 32-bit arch*/
    return rem;
}
/*
TODO:
 unsigned int __udivsi3 (unsigned int a, unsigned int b)
 unsigned long __udivdi3 (unsigned long a, unsigned long b)
 unsigned long long __udivti3 (unsigned long long a, unsigned long long b)
*/
