
REMOVE = rm -rf

GCC = $(RISCV)/bin/riscv64-unknown-elf-gcc
LD = $(RISCV)/bin/riscv64-unknown-elf-ld
AS = $(RISCV)/bin/riscv64-unknown-elf-as

# -march=RV32IM  only integer instructions 
#  mul & div issue:
#    32 bit integers --> hardware instructions
#    64 bit integers --> use GCC integer arithmetic emulation routines bindings

# -msoft-float  use GCC soft float emulation routines bindings.

GCC_OPTS = -m32 -march=RV32IM -mmuldiv -Wno-implicit-int -Wno-implicit-function-declaration -O3 -Ofast -fno-inline-functions -static -fno-common -ffreestanding -msoft-float -fomit-frame-pointer -nostartfiles -nostdinc -I ./

bmarks_defs = -DMSC_CLOCK

sfp_lib_dir = ./softfloat


all:: build

startup.o: startup.s
	$(AS) -m32 -march=RV32I startup.s -o startup.o

dhry.a: dhry_1.c dhry_2.c
	#-Istdlib -- include path our stdlib replacement
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c dhry_1.c -I ./stdlib -o dhry_1.o 
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c dhry_2.c -I ./stdlib -o dhry_2.o
	$(AR) rcs dhry.a dhry_1.o dhry_2.o

#Standard library calls replacement
my_stdlib.o: stdlib.c
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c stdlib.c -o my_stdlib.o

#floating point emulation routines
soft_fp.a: $(sfp_lib_src)
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(sfp_lib_dir)/gcc_trampolines.c -o trampolines.o
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(sfp_lib_dir)/softfloat.c -o softfloat.o 
	$(AR) rcs soft_fp.a trampolines.o softfloat.o 

# Routines for integer 64 bit mul & div arithmetic (RICV RV32IM)
int64_ariph.a: div.s int64_ariph.c
	$(AS) -m32 -march=RV32I div.s -o div.o
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c int64_ariph.c -o int64_ariph.o 
	$(AR) rcs int64_ariph.a int64_ariph.o div.o 

build: dhry.a startup.o my_stdlib.o soft_fp.a int64_ariph.a
	$(LD) -nostdlib  -T dhrystone.ld dhry.a startup.o my_stdlib.o soft_fp.a int64_ariph.a -o dhrystone.elf 

clean:
	$(REMOVE) *.elf *.o *.a














