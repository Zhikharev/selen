
REMOVE = rm -rf

CCX = $(RISCV)/bin/riscv64-unknown-elf-gcc
LD = $(RISCV)/bin/riscv64-unknown-elf-ld
AS = $(RISCV)/bin/riscv64-unknown-elf-as


all:: build

startup.o : startup.s
	$(AS) -m32 startup.s -o startup.o

blink.o : blink.c
	$(CCX) -c blink.c -Wall -fomit-frame-pointer -m32 -O2 -o tmp.o

test.s : blink.c
	$(CCX) -S blink.c -Wall -fomit-frame-pointer -fverbose-asm -nostdlib -m32 -O2 -o test.s

build: blink.c startup.o
	$(CCX) -c blink.c -Wall -fomit-frame-pointer  -m32 -O2 -o tmp.o
	$(LD) -T blink.ld tmp.o -o prog.elf 

clean:
	$(REMOVE) test.s prog.elf *.o














