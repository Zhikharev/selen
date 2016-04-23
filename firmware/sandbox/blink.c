/*test program*/

#include "gpio_config.h"

#define STATIC_ASSERT(COND) typedef char static_assertion[(COND)?1:-1]

/*Target - riscv 32.  SIZE_TYPE check*/
STATIC_ASSERT(sizeof(__SIZE_TYPE__) == 4);

typedef __SIZE_TYPE__ uint32_t;

#pragma pack(push, 4)
/*
  pack     - aligment and no paddings
  volatile - compiler strict about memory stores and loads
*/
typedef volatile struct
{
    uint32_t in;
    uint32_t out;
    uint32_t oe;
    uint32_t inte;
    uint32_t ptrig;
    uint32_t aux;
    uint32_t ctrl;
    uint32_t eclk;
    uint32_t nec;
} GPIO;
#pragma pack(pop)

/* check GPIO struct memory layout fit*/
STATIC_ASSERT(sizeof(GPIO) == GPIO_NUM_REGS * sizeof(uint32_t));

typedef __UINT64_TYPE__ tick_t;

static inline
tick_t get_tick()
{
    uint32_t low;
    uint32_t high;

    /*load low and high parts of counter*/
    asm volatile("rdcycle %0;\n\trdcycleh %1;" : "=r"(low) , "=r"(high));

    return (((tick_t)high) << 32) | low;
}

/*Timer, active wait*/
static
void wait(const tick_t ticks_to_wait)
{
    tick_t ticks_elapsed = 0;
    const tick_t begin = get_tick();

    while(ticks_elapsed < ticks_to_wait)
    {
        ticks_elapsed = get_tick() - begin;
    }
}

#define BIT_MASK(n) ((uint32_t)1 << n)

/*set name for linker*/
void blink() asm("main");


#define NUM_BLINKS 100
/*cpu ticks to one iteration*/
#define BLINK_PERIOD 100


void __attribute__((optimize("Os"))) blink()
{
    const uint32_t input_pin = 0;
    const uint32_t output_pin = 1;

    /*map GPIO struct to memory*/
    GPIO* const gpio = (GPIO*)GPIO_BASE_ADDRESS;

    /*init default settings*/
    gpio->in = GPIO_DEF_RGPIO_IN;
    gpio->out = GPIO_DEF_RGPIO_OUT;
    gpio->oe = GPIO_DEF_RGPIO_OE;
    gpio->inte = GPIO_DEF_RGPIO_INTE;
    gpio->ptrig = GPIO_DEF_RGPIO_PTRIG;
    gpio->aux = GPIO_DEF_RGPIO_AUX;
    gpio->ctrl = GPIO_DEF_RGPIO_CTRL;
    gpio->eclk = GPIO_DEF_RGPIO_ECLK;
    gpio->nec = GPIO_DEF_RGPIO_NEC;

    /*Set input pin*/
    gpio->oe &= ~(BIT_MASK(input_pin));

    /*disable generation of interrupts*/

    /*global*/
    gpio->ctrl &= ~(BIT_MASK(GPIO_RGPIO_CTRL_INTE));
    /*disable interrupts fot input pin*/
    gpio->inte &= ~(BIT_MASK(input_pin));

    /* wait for event through polling*/
    while(1)
    {
        if(gpio->in & BIT_MASK(input_pin))
            break;
    }

    /*Set output pin*/
    gpio->oe |= (BIT_MASK(output_pin));
    /*disable interrupts fot output pin*/
    gpio->inte &= ~(BIT_MASK(output_pin));

    for(uint32_t i = 0; i < NUM_BLINKS; i++)
    {
        /*set high level signal at output_pin*/
        gpio->out |= (BIT_MASK(output_pin));

        wait(BLINK_PERIOD);

        /*set low level signal at output_pin*/
        gpio->out &= ~(BIT_MASK(output_pin));

        wait(BLINK_PERIOD);
    }
}
