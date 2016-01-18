
REMOVE = rm -rf
DD = dd
BINDIR = /home/jettatura/bin/riscv/bin

CCX = $(BINDIR)/riscv64-unknown-elf-gcc
AS = $(BINDIR)/riscv64-unknown-elf-as
LD = $(BINDIR)/riscv64-unknown-elf-ld
OBJCOPY = $(BINDIR)/riscv64-unknown-elf-objcopy
OBJDUMP = $(BINDIR)/riscv64-unknown-elf-objdump

IMAGE_SIZE=4096
IMAGE_NAME="flash.bin"

all:: build

startup.o : startup.s
	$(AS) -m32 startup.s -g -o startup.o

prog.o : prog.cpp
	$(CCX) -m32 -c -o prog.o prog.cpp

#view assemble
prog.s : prog.cpp
	$(CCX) -m32 -S -o prog.s prog.cpp

prog.elf : prog.o startup.o
	$(LD) -melf32lriscv -T linker.ld startup.o prog.o -o prog.elf

#view instructions at elf
view: prog.elf
	$(OBJDUMP) -d prog.elf 

prog.bin : prog.elf
	$(OBJCOPY) -O binary -S --set-start 0 prog.elf prog.bin

build: prog.bin
	$(DD) if=prog.bin of=$(IMAGE_NAME) bs=$(IMAGE_SIZE) conv=notrunc

clean:
	$(REMOVE) *.o prog.s *.elf *bin
