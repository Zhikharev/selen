/*test program*/

#include "gpio_config.h"

typedef unsigned int uint32_t;

#pragma pack(push, 4)
typedef struct
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

/*GPIO.ctrl bits*/
enum
{
    CTRL_INTE = 0, /* When set, interrupt generation is enabled.
                   When cleared, interrupts are masked. */
    CTRL_INTS   /*When set, interrupt is pending.
                  When cleared, no interrupt pending.*/
};

static
void* memcpy(void* dest, const void* src, uint32_t count)
{
    char* dst8 = (char*)dest;
    char* src8 = (char*)src;

    while (count--)
    {
        *dst8++ = *src8++;
    }
    return dest;
}

void set_gpio(uint32_t* gpio_base, const GPIO* value)
{
    memcpy(gpio_base, value, sizeof(GPIO));
}

void get_gpio(uint32_t* gpio_base, GPIO* value)
{
    memcpy(value, gpio_base, sizeof(GPIO));
}

#define BIT_MASK(n) ((uint32_t)1 << n)

int main()
{
    uint32_t gpio_base = 0x2000;

    uint32_t input_pin = 0;
    uint32_t output_pin = 1;

    /*volatile*/ GPIO param;

    /*default settings*/
    param.in = GPIO_DEF_RGPIO_IN;
    param.out = GPIO_DEF_RGPIO_OUT;
    param.oe = GPIO_DEF_RGPIO_OE;
    param.inte = GPIO_DEF_RGPIO_INTE;
    param.ptrig = GPIO_DEF_RGPIO_PTRIG;
    param.aux = GPIO_DEF_RGPIO_AUX;
    param.ctrl = GPIO_DEF_RGPIO_CTRL;
    param.eclk = GPIO_DEF_RGPIO_ECLK;
    param.nec = GPIO_DEF_RGPIO_NEC;

    /*Set input pin*/
    param.oe = param.oe & ~(BIT_MASK(input_pin));

    /*disable generation of interrupts*/

    /*global*/
    param.ctrl = param.ctrl & ~(BIT_MASK(CTRL_INTE));
    /*disable interrupts fot input pin*/
    param.inte = param.inte & ~(BIT_MASK(input_pin));

    set_gpio((uint32_t*) gpio_base, &param);

    /* wait for event through polling*/
    while(1)
    {
        get_gpio((uint32_t*) gpio_base, &param);

        if(param.in & BIT_MASK(input_pin))
            break;
    }

    /*Set output pin*/
    param.oe = param.oe & (BIT_MASK(output_pin));
    /*disable interrupts fot output pin*/
    param.inte = param.inte & ~(BIT_MASK(output_pin));

    /*
    4) используя таймер ядра инвертировать значение для пина 1 (мигание)\
    ????q:q
    */
    return 1;
}
