
HOME := $(dir $(lastword $(MAKEFILE_LIST)))
BIT ?= 64
REMOVE = rm -rf

AS 		  = $(RISCV)/bin/riscv$(BIT)-unknown-elf-as
GCC     = $(RISCV)/bin/riscv$(BIT)-unknown-elf-gcc
LD      = $(RISCV)/bin/riscv$(BIT)-unknown-elf-ld


# -march=RV32IM  only integer instructions
#  mul & div issue:
#    32 bit integers --> hardware instructions
#    64 bit integers --> use GCC integer arithmetic emulation routines bindings

# -msoft-float  use GCC soft float emulation routines bindings.

# Get errors
# riscv32-unknown-elf-ld -nostdlib  -T //media/sf_selen.git/firmware/sandbox/dhrystone//dhrystone.ld dhry.a startup.o my_stdlib.o soft_fp.a int64_ariph.a -o dhrystone.elf
# riscv32-unknown-elf-ld: dhry.a(dhry_1.o): can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file dhry.a(dhry_1.o)
# riscv32-unknown-elf-ld: dhry.a(dhry_2.o): can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file dhry.a(dhry_2.o)
# riscv32-unknown-elf-ld: my_stdlib.o: can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file my_stdlib.o
# riscv32-unknown-elf-ld: soft_fp.a(trampolines.o): can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file soft_fp.a(trampolines.o)
# riscv32-unknown-elf-ld: soft_fp.a(softfloat.o): can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file soft_fp.a(softfloat.o)
# riscv32-unknown-elf-ld: int64_ariph.a(int64_ariph.o): can't link hard-float modules with soft-float modules
# riscv32-unknown-elf-ld: failed to merge target specific data of file int64_ariph.a(int64_ariph.o)
#GCC_OPTS = \
	-m32 -march=RV32IM -mmuldiv -Wno-implicit-int -Wno-implicit-function-declaration \
  -O3 -Ofast -fno-inline-functions -static -fno-common -ffreestanding -msoft-float \
  -fomit-frame-pointer -nostartfiles -nostdinc -I $(HOME)

GCC_OPTS = \
	-m32 -march=RV32IM -mmuldiv -Wno-implicit-int -Wno-implicit-function-declaration \
  -O3 -Ofast -fno-inline-functions -static -fno-common -ffreestanding  \
  -fomit-frame-pointer -nostartfiles -nostdinc -I $(HOME)

bmarks_defs = -DMSC_CLOCK

sfp_lib_dir = $(HOME)/softfloat


all:: build

startup.o:
	$(AS) -m32 -march=RV32I $(HOME)/startup.s -o startup.o

dhry.a:
	#-Istdlib -- include path our stdlib replacement
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(HOME)/dhry_1.c -I ./stdlib -o dhry_1.o
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(HOME)/dhry_2.c -I ./stdlib -o dhry_2.o
	$(AR) rcs dhry.a dhry_1.o dhry_2.o

#Standard library calls replacement
my_stdlib.o:
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(HOME)/stdlib.c -o my_stdlib.o

#floating point emulation routines
soft_fp.a:
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(sfp_lib_dir)/gcc_trampolines.c -o trampolines.o
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(sfp_lib_dir)/softfloat.c -o softfloat.o
	$(AR) rcs soft_fp.a trampolines.o softfloat.o

# Routines for integer 64 bit mul & div arithmetic (RICV RV32IM)
int64_ariph.a:
	$(AS) -m32 -march=RV32I $(HOME)/div.s -o div.o
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c $(HOME)/int64_ariph.c -o int64_ariph.o
	$(AR) rcs int64_ariph.a int64_ariph.o div.o

build: dhry.a startup.o my_stdlib.o soft_fp.a int64_ariph.a
	$(LD) -nostdlib  -T $(HOME)/dhrystone.ld dhry.a startup.o my_stdlib.o soft_fp.a int64_ariph.a -o dhrystone.elf

clean:
	$(REMOVE) *.elf *.o *.a














