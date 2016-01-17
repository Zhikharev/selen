#! /bin/bash

#поправь пути.
IMAGE_SIZE=4096
IMAGE_NAME="flash.bin"

#скомпилировать cpp файл riscv-gcc без startup кода, без билиотек
#если несколько файлов используй скрипт для линкера
/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -o temp.elf test.cpp

#просто ассемблировать чтобы посмореть инструкции
/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -S -o temp.s test.cpp

#конвертировать elf в binary, -S -полный strip.
/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-objcopy -O binary -S --set-start 0 temp.elf temp.bin

#сделать image.
#просто вставить temp.bin в начало куска нулей нужного размера. 
dd if=temp.bin of=$IMAGE_NAME bs=$IMAGE_SIZE conv=notrunc

#Запускать в симуляторе
#./sim -img  ../src/sim/bare_metal/flash.bin -i -e BE

#BE - big endian, это издержки недопонимания от транслятора gipnocow в нашем случае.

