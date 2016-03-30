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

int main()
{
    printf("start test\n");

    s_model_params params;

    params.pc_start = 0x200;
    params.mem_size = 42949;
    params.verbose = 1;
    params.mem_resize = 0;
    params.endianness = 0;

    TEST(init(&params));

    TEST(set_mem(0x200,  0x14802383));
    TEST(set_mem(0x204,  0x3f202303));
    TEST(step());

    return EXIT_SUCCESS;
}
