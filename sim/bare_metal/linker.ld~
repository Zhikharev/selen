ENTRY(main)
SECTIONS
{
 . = 0x0;
 .text : { *(.text) }
 .data : { *(.data) }
 . = ALIGN(4);
 . = . + 0x1000; /* 4kB of stack memory */
 stack_top = .;
}
