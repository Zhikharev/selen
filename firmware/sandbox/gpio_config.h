#ifndef GPIO_CONFIG_INCLUDE_ONCE_123456
#define GPIO_CONFIG_INCLUDE_ONCE_123456
/*GPIO config*/

/* !!!!!!!
 * NOTE: gpio_base pointer should reference to non cashable memory!
 *  (no need for memory bariers to set up GPIO memory maped registers)
 * !!!!!!!
*/
#define GPIO_BASE_ADDRESS 0x2000

/*
 Number of GPIO I/O signals

 This is the most important parameter of the GPIO IP core. It defines how many
 I/O signals core has. Range is from 1 to 32. If more than 32 I/O signals are
 required, use several instances of GPIO IP core.

 Default is 16.
*/
#define GPIO_IOS 31

/*
 Addresses of GPIO registers

 To comply with GPIO IP core specification document they must go from
 address 0 to address 0x18 in the following order.

 If particular register is not needed, it's address definition can be omitted
 and the register will not be implemented. Instead a fixed default value will
 be used.
*/

/*GPIO input data*/
#define GPIO_RGPIO_IN 0x00
/*GPIO output data*/
#define GPIO_RGPIO_OUT 0x04
/*GPIO output driver enable*/
#define GPIO_RGPIO_OE 0x08
/*Interrupt enable*/
#define GPIO_RGPIO_INTE 0x0c
/*Type of event that triggers an interrupt*/
#define GPIO_RGPIO_PTRIG 0x10
/*Multiplex auxiliary inputs to GPIO outputs*/
#define GPIO_RGPIO_AUX 0x14
/*Control register*/
#define GPIO_RGPIO_CTRL 0x18
/*Interrupt status*/
#define GPIO_RGPIO_INTS 0x1c
/*Enable gpio_eclk to latch RGPIO */
#define GPIO_RGPIO_ECLK 0x20
/* Select active edge of gpio_eclk */
#define GPIO_RGPIO_NEC 0x24


/*Amount of register*/
#define GPIO_NUM_REGS 9

/*
 Default values for unimplemented GPIO registers
*/
#define GPIO_DEF_RGPIO_IN 0
#define GPIO_DEF_RGPIO_OUT 0
#define GPIO_DEF_RGPIO_OE 0
#define GPIO_DEF_RGPIO_INTE 0
#define GPIO_DEF_RGPIO_PTRIG 0
#define GPIO_DEF_RGPIO_AUX 0
#define GPIO_DEF_RGPIO_CTRL 0
#define GPIO_DEF_RGPIO_ECLK 0
#define GPIO_DEF_RGPIO_NEC 0

/*
 RGPIO_CTRL bits

 To comply with the GPIO IP core specification document they must go from
 bit 0 to bit 1 in the following order: INTE, INT
*/
#define GPIO_RGPIO_CTRL_INTE 0
#define GPIO_RGPIO_CTRL_INTS 1

#endif /* GPIO_CONFIG_INCLUDE_ONCE_123456 */
