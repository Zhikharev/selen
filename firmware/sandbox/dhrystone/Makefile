
REMOVE = rm -rf

GCC = $(RISCV)/bin/riscv64-unknown-elf-gcc
LD = $(RISCV)/bin/riscv64-unknown-elf-ld
AS = $(RISCV)/bin/riscv64-unknown-elf-as

#-msoft-float  нужно найти softfloat library
GCC_OPTS =  -O3 -Ofast -fno-inline-functions -m32 -static -fno-common -ffreestanding -fomit-frame-pointer -nostartfiles -nostdinc -I ./

bmarks_defs = -DMSC_CLOCK

all:: build

startup.o: startup.s
	$(AS) -m32 startup.s -o startup.o

dhry_1.o: dhry_1.c
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c dhry_1.c -o dhry_1.o

dhry_2.o: dhry_2.c
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c dhry_2.c -o dhry_2.o

my_stdlib.o: stdlib.c
	$(GCC) $(GCC_OPTS) $(bmarks_defs) -c stdlib.c -o my_stdlib.o


build: dhry_2.o dhry_1.o startup.o my_stdlib.o
	$(LD) -nostdlib  -T dhrystone.ld dhry_2.o dhry_1.o startup.o my_stdlib.o -o dhrystone.elf 

clean:
	$(REMOVE) *.elf *.o














