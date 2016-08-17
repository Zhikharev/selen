# Startup code for blink.c

    .text

    .global _start

_start:

    #set up stack
    la sp, _stack_top

    # set global pointer, no need now
    #la gp, global_top

    call main

# an infinite loop, long enought to see it at trace
   .global _exit
_exit:
    nop
    nop
    nop
    nop
    nop
    j _exit

