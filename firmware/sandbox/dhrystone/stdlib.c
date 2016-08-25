#include "./time.h"
#include "./stdio.h"

typedef __SIZE_TYPE__ size_t;
typedef __UINT8_TYPE__ uint8_t;
typedef __UINT32_TYPE__ uint32_t;

typedef __PTRDIFF_TYPE__ ptrdiff_t;

#define assert(pred) if(!(pred)) asm ("j _exit\n")

#define NULL 0

#define DHRYSTONE_NUM_ITERATIONS 100

//int errno = 0; FIXME:

int printf ( const char * format, ... )
{
    return 1;
}

int scanf (const char * format, int *n)
{
    *n = DHRYSTONE_NUM_ITERATIONS; /*HACK*/
    return 1;
}

int strcmp ( const char * str1, const char * str2 )
{
    const uint8_t *p1 = (const uint8_t *)str1;
    const uint8_t *p2 = (const uint8_t *)str2;

    while (*p1 != '\0') {
        if (*p2 == '\0')
            return  1;
        if (*p2 > *p1)
            return -1;
        if (*p1 > *p2)
            return  1;

        p1++;
        p2++;
    }

    if (*p2 != '\0')
        return -1;

    return 0;
}


char * strcpy ( char * destination, const char * source )
{
    assert(destination != NULL && source != NULL);
    char *temp = destination;
    while(*destination++ = *source++)
        ;
    return temp;
}

clock_t	clock()
{
    uint32_t low;
    uint32_t high;

    /*load low and high parts of counter*/
    asm volatile("rdcycle %0;\n\trdcycleh %1;" : "=r"(low) , "=r"(high));

    return (((clock_t)high) << 32) | low;
}


void* heap_end = 0;

void* _sbrk(ptrdiff_t incr) {
    extern void* heap_low; /* Defined by the linker */
    extern void* heap_top; /* Defined by the linker */
    void* prev_heap_end;

    if (heap_end == 0) {
        heap_end = heap_low;
    }
    prev_heap_end = heap_end;

    if (heap_end + incr > heap_top) {
        /* Heap and stack collision */
        return (void*)-1;
    }

    heap_end += incr;
    return prev_heap_end;
}

void free(void* ptr)
{
    /*TODO:*/
}

/* FIXME: An horrible dummy malloc */
void *malloc(const size_t size)
{
   void *p = (void*)_sbrk (0);

    /* If sbrk fails , we return NULL*/
    if ( (void*)_sbrk(size) == (void *)-1)
        return NULL;

    return p;
}
