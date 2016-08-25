/*
    Jettatura 2016

    Trampoline functions that bind GCC Routines for floating point emulation ("-msoft_float" flag) to Berkeley SoftFloat IEEE Floating-Point
    Arithmetic Package, Release 2c, by John R. Hauser.
*/

#include "softfloat.h"

/*These functions convert i, a signed integer, to floating point. */
uint32 __floatsisf (int32 i)
{
    return int32_to_float32(i);
}
/* TODO:
    double __floatsidf (int i);
    long double __floatsitf (int i);
    long double __floatsixf (int i);
*/


/*These functions return the product of a and b. */
uint32 __mulsf3 (uint32 a, uint32 b)
{
    return float32_mul(a,b);
}

uint64 __muldf3 (uint64 a, uint64 b)
{
    return float64_mul(a, b);
};
/* TODO:
    long double __multf3 (long double a, long double b);
    long double __mulxf3 (long double a, long double b);
*/


/* These functions return the quotient of a and b; that is, a / b.  */
uint32 __divsf3 (uint32 a, uint32 b)
{
    return float32_div(a,b);
};

uint64 __divdf3 (uint64 a, uint64 b)
{
    return float64_div(a,b);
};

/* TODO:
    long double __divtf3 (long double a, long double b);
    long double __divxf3 (long double a, long double b);
*/


/*These functions extend a to the wider mode of their return type. */
uint64 __extendsfdf2 (uint32 a)
{
    return float32_to_float64(a);
};
/*TODO:
    long double __extendsftf2 (float a);
    long double __extendsfxf2 (float a);
    long double __extenddftf2 (double a);
    long double __extenddfxf2 (double a);
*/


/*These functions truncate a to the narrower mode of their return type, rounding toward zero. */
uint32 __truncdfsf2 (uint64 a)
{
    return float64_to_float32(a);
};
/*TODO:
    double __truncxfdf2 (long double a);
    double __trunctfdf2 (long double a);
    float __truncxfsf2 (long double a);
    float __trunctfsf2 (long double a);
*/
