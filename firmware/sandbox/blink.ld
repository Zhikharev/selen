OUTPUT_ARCH( "riscv:rv32" )

ENTRY( _entry )
/*_entry here*/
INPUT(startup.o)

/*supported formats:
    elf64-littleriscv elf32-littleriscv
    elf64-little elf64-big
    elf32-little elf32-big
    plugin srec symbolsrec verilog tekhex binary ihex
*/
OUTPUT_FORMAT("elf32-littleriscv")

SECTIONS
{
  . = 0x00010000;

  /* code segment */
  .text : {
    startup.o(.text)
    *(.text)
  }

  /* Writable initialized data */
  . = ALIGN(16);
  .data : { *(.data) }

  /* RISC-V calling convention, the stack grows downward and the stack pointer is
    always kept 16-byte aligned. */
  . = ALIGN(16);
  . = . + 0x1000; /* 4kB of stack memory */
  _stack_top = .;
}
