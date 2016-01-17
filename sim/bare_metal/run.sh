#! /bin/bash

IMAGE_SIZE=4096
IMAGE_NAME="flash.bin"

/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -Ttext=0x0 -o temp.elf test.cpp

/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -S -o temp.s test.cpp

/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-objcopy -O binary -S --set-start 0 temp.elf temp.bin

dd if=temp.bin of=$IMAGE_NAME bs=$IMAGE_SIZE conv=notrunc

#Запускать в симуляторе
#./sim -img  ../src/sim/bare_metal/flash.bin -i -e BE

