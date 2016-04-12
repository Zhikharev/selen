#ifndef GPIO_CONFIG_INCLUDE_ONCE_123456
#define GPIO_CONFIG_INCLUDE_ONCE_123456
/*GPIO config*/

/*
 Number of GPIO I/O signals

 This is the most important parameter of the GPIO IP core. It defines how many
 I/O signals core has. Range is from 1 to 32. If more than 32 I/O signals are
 required, use several instances of GPIO IP core.

 Default is 16.
*/
#define GPIO_IOS 31

/*
 depending on number of GPIO_IOS, define this...
 for example: if there is 26 GPIO_IOS, define GPIO_LINES26
*/
#define GPIO_LINES31

/*
 Undefine this one if you don't want to remove GPIO block from your design
 but you also don't need it. When it is undefined, all GPIO ports still
 remain valid and the core can be synthesized however internally there is
 no GPIO funationality.
*/
#define GPIO_IMPLEMENTED

/*
 Define to register all WISHBONE outputs.

 Register outputs if you are using GPIO core as a block and synthesizing
 and place&routing it separately from the rest of the system.

 If you do not need registered outputs, you can save some area by not defining
 this macro. By default it is defined.
*/
#define GPIO_REGISTERED_WB_OUTPUTS

/*
 Define to register all GPIO pad outputs.

 Register outputs if you are using GPIO core as a block and synthesizing
 and place&routing it separately from the rest of the system.

 If you do not need registered outputs, you can save some area by not defining
 this macro. By default it is defined.
*/
#define GPIO_REGISTERED_IO_OUTPUTS

/*
 Define to avoid using negative edge clock flip-flops for external clock
 (caused by NEC register. Instead an inverted external clock with
 positive edge clock flip-flops will be used.

 By default it is not defined.
*/
#define GPIO_NO_NEGEDGE_FLOPS

/*
 If GPIO_NO_NEGEDGE_FLOPS is defined, a mux needs to be placed on external clock
 clk_pad_i to implement RGPIO_CTRL[NEC] functionality. If no mux is allowed on
 clock signal, enable the following define.

 By default it is not defined.
*/
#define GPIO_NO_CLKPAD_LOGIC

/*
 Undefine if you don't need to read GPIO registers except for RGPIO_IN register.
 When it is undefined all reads of GPIO registers return RGPIO_IN register. This
 is usually useful if you want really small area (for example when implemented in
 FPGA).

 To follow GPIO IP core specification document this one must be defined. Also to
 successfully run the test bench it must be defined. By default it is defined.
*/
#define GPIO_READREGS

/*
 Full WISHBONE address decoding

 It is is undefined, partial WISHBONE address decoding is performed.
 Undefine it if you need to save some area.

 By default it is defined.
*/
#define GPIO_FULL_DECODE

/*
 Strict 32-bit WISHBONE access

 If this one is defined, all WISHBONE accesses must be 32-bit. If it is
 not defined, err_o is asserted whenever 8- or 16-bit access is made.
 Undefine it if you need to save some area.

 By default it is defined.
*/
#define GPIO_STRICT_32BIT_ACCESS

/*
 WISHBONE address bits used for full decoding of GPIO registers.
*/

#define GPIO_ADDRHH 7
#define GPIO_ADDRHL 6
#define GPIO_ADDRLH 1
#define GPIO_ADDRLL 0

/*
 Bits of WISHBONE address used for partial decoding of GPIO registers.

 Default 5:2.
*/
/*#define GPIO_OFS_BITS GPIO_ADDRHL-1:GPIO_ADDRLH+1
*/

/*
 Addresses of GPIO registers

 To comply with GPIO IP core specification document they must go from
 address 0 to address 0x18 in the following order: RGPIO_IN, RGPIO_OUT,
 RGPIO_OE, RGPIO_INTE, RGPIO_PTRIG, RGPIO_AUX and RGPIO_CTRL

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
