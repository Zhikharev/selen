#include <stdio.h>
#include <stdlib.h>

#include "core_model_dpi.h"

#define TEST(function) \
    printf("test " #function "...");\
    if(function != RC_SUCCESS)\
    {\
        printf("Fail!\n");\
        return EXIT_FAILURE;\
    }\
    printf("Passed\n");


int test1()
{
    /*
     *   0: memory WRITE; size 4 bytes; addr 0x00000200; value 0x14802383
         1: memory WRITE; size 4 bytes; addr 0x00000204; value 0x3f202303
         2: memory  READ; size 4 bytes; addr 0x00000200; value 0x14802383
         3:         ||-- 0x00000200  0x14802383     LW   t2, [zero + 0x148]
         4: register  READ; id 0 -> zero; value  0x00000000
         5: memory  READ; size 4 bytes; addr 0x00000148; value 0x00000000
         6: register WRITE; id 7 -> t2; value  0x00000000; diff 0 (0)
     */
    s_model_params params;

    params.pc_start = 0x200;
    params.mem_size = 42949;
    params.verbosity_level = 1;
    params.trace_file = 1;
    params.trace_console = 0;
    params.mem_resize = 0;
    params.endianness = 0;

    TEST(init(&params));

    TEST(set_mem(0x200,  0x14802383));
    TEST(set_mem(0x204,  0x3f202303));
    TEST(step());

    return EXIT_SUCCESS;
}

int main()
{
    printf("start test\n");

    /*test1();*/

    /*
    0: memory WRITE; size 4 bytes; addr 0x00000200; value 0xa2202d83
    1: memory WRITE; size 4 bytes; addr 0x00000204; value 0x55e02183
    2: memory WRITE; size 4 bytes; addr 0xfffffa22; value 0x6f7d4b4b
    3: memory WRITE; size 4 bytes; addr 0x00000208; value 0xfbd029a3

    36: memory READ; size 4 bytes; addr 0x00000200; value 0x00000000
    37: ||-- 0x00000200 0x00000000 invalid
    38: memory WRITE; size 4 bytes; addr 0x0000055e; value 0x36e9840f
    39: memory WRITE; size 4 bytes; addr 0x0000020c; value 0x42e04203
    */

    s_model_params params;

    params.pc_start = 0x200;
    params.mem_size = 1;
    params.verbosity_level = 1;
    params.trace_file = 1;
    params.trace_console = 0;
    params.mem_resize = 1;
    params.endianness = 0;

    TEST(init(&params));

    TEST(set_mem(0x200,  0xa2202d83));
    TEST(set_mem(0x204,  0x55e02183));
    TEST(set_mem(0xfffffa22,  0x6f7d4b4b));
    TEST(set_mem(0x00000208,  0xfbd029a3));

    TEST(step());


    return EXIT_SUCCESS;
}
