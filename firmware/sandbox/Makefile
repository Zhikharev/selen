
REMOVE = rm -rf

CCX = $(RISCV)/bin/riscv64-unknown-elf-gcc
LD  = $(RISCV)/bin/riscv64-unknown-elf-ld

all:: build

build: blink.c
	$(CCX) -S blink.c -nostdlib -m32 -O2 -o test.s

clean:
	$(REMOVE) test.s
