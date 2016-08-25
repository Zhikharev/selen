OUTPUT_ARCH( "riscv:rv32" )

ENTRY( _start )

/*supported formats:
    elf64-littleriscv elf32-littleriscv
    elf64-little elf64-big
    elf32-little elf32-big
    plugin srec symbolsrec verilog tekhex binary ihex
*/

OUTPUT_FORMAT("elf32-littleriscv")

SECTIONS
{
  . = 0x00100000;

  .ro : {
  /* code segment */
   startup.o (.text)
   *(.text)
  /* constants */
   *(.rodata)
  }

  /* Writable data */
  . = ALIGN(16);
  .rw : {
   *(.data)
   *(.bss)
   *(COMMON)
  }

  /* heap for malloc*/
  . = ALIGN(8);
  heap_low = .; /* for _sbrk */
  . = . + 0x10000; /* 64kB of heap memory */
  heap_top = .; /* for _sbrk */

  /* RISC-V calling convention: the stack grows downward and the stack pointer is
    always kept 16-byte aligned. */
  . = ALIGN(16);
  . = . + 0x10000; /* 64kB of stack memory */
  _stack_top = .; /*init value sp register*/
}
