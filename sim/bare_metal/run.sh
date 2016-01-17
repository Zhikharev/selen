#! /bin/bash

#поправь пути.
IMAGE_SIZE=4096
IMAGE_NAME="flash.bin"

#скомпилировать cpp файл riscv-gcc без startup кода, без билиотек
#если несколько файлов используй скрипт для линкера
/home/jettatura/bin/riscv/bin/riscv64-unknown-linux-gnu-gcc -nostdlib -nostartfiles -o temp.elf test.cpp

#просто ассемблировать чтобы посмореть инструкции
/home/jettatura/bin/riscv/bin/riscv64-unknown-linux-gnu-gcc -nostdlib -nostartfiles -S -o temp.s test.cpp

#конвертировать elf в binary, -S -полный strip.
#entry point, он же start address определяется необходимостью 
/home/jettatura/bin/riscv/bin/riscv64-unknown-linux-gnu-objcopy -O binary -S --set-start 0 temp.elf temp.bin

#сделать image.
#просто вставить temp.bin в начало куска нулей нужного размера. 
dd if=temp.bin of=$IMAGE_NAME bs=$IMAGE_SIZE conv=notrunc



#Запускать в симуляторе
#./sim -img  ../src/sim/bare_metal/flash.bin -i -e BE


#BE - big endian, это издержки недопонимания от транслятора gipnocow в нашем случае.
#да и как видишь не все инструкции у на одинаковые

#Selen isa simulator 2015.
#Parameters:
#                  image file: ../src/sim/bare_metal/flash.bin
#               state dump to: id.txt
#               state dump to: fd.txt
#                      regime: interactive
#            Simulator config: 
#                     tracing: on
#                  endianness: BE
#          address space size: 1222222 bytes
#                    start pc: 0
#                       steps: 0
#Simulator at unteractive regime
#(isa-sim): l
#image ../src/sim/bare_metal/flash.bin was loaded to simulator memory at address 0
#(isa-sim): d 0
#dissasemble 10 words from address 0
#         0	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
#       0x4	  0x813c23	STORE-type invalid func3 field: opcode= #func3= 0x3
#       0x8	 0x2010413	  ADDI	 T0,  V0, 0x20
#       0xc	  0x100793	  ADDI	 T7, ZERO, 0x1
#      0x10	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
#      0x14	  0x300793	  ADDI	 T7, ZERO, 0x3
#      0x18	0xfef42223	    SW	 T0, [ T7 + 0xffffffe4]
#      0x1c	0xfe042623	    SW	 T0, [ZERO + 0xffffffec]
#      0x20	0xfec42703	    LW	 T6, [ T0 + 0xffffffec]
#      0x24	  0x300793	  ADDI	 T7, ZERO, 0x3
#(isa-sim): d 0 125
#dissasemble 125 words from address 0
#         0	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
#       0x4	  0x813c23	STORE-type invalid func3 field: opcode= #func3= 0x3
#       0x8	 0x2010413	  ADDI	 T0,  V0, 0x20
#       0xc	  0x100793	  ADDI	 T7, ZERO, 0x1
#      0x10	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
#      0x14	  0x300793	  ADDI	 T7, ZERO, 0x3
#      0x18	0xfef42223	    SW	 T0, [ T7 + 0xffffffe4]
#      0x1c	0xfe042623	    SW	 T0, [ZERO + 0xffffffec]
#      0x20	0xfec42703	    LW	 T6, [ T0 + 0xffffffec]
#      0x24	  0x300793	  ADDI	 T7, ZERO, 0x3
#      0x28	 0x2e7c063	   BLT	 T7,  T6, [0x20]
#      0x2c	0xfe442783	    LW	 T7, [ T0 + 0xffffffe4]
#      0x30	  0x17879b	invalid, opcode: 0x1b
#      0x34	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
#      0x38	0xfec42783	    LW	 T7, [ T0 + 0xffffffec]
#      0x3c	  0x17879b	invalid, opcode: 0x1b
#      0x40	0xfef42623	    SW	 T0, [ T7 + 0xffffffec]
#      0x44	0xfddff06f	   JAL	ZERO, 0xffffffdc
#      0x48	0xfe842783	    LW	 T7, [ T0 + 0xffffffe8]
#      0x4c	   0x78513	  ADDI	 T2,  T7, 0
#      0x50	 0x1813403	LOAD-type invalid func3 field: opcode= func3= 0x3
#      0x54	 0x2010113	  ADDI	 V0,  V0, 0x20
#      0x58	    0x8067	  JALR	ZERO, 0
#      0x5c	0x3b031b01	invalid, opcode: 0x1
#      0x60	      0x10	invalid, opcode: 0x10
#      0x64	       0x1	invalid, opcode: 0x1
#      0x68	0xffffffa4	invalid, opcode: 0x24
#      0x6c	      0x2c	invalid, opcode: 0x2c
#      0x70	      0x14	invalid, opcode: 0x14
#      0x74	         0	invalid, opcode: 0
#      0x78	  0x527a01	invalid, opcode: 0x1
#      0x7c	 0x1010801	invalid, opcode: 0x1
#      0x80	   0x20d1b	invalid, opcode: 0x1b
#      0x84	         0	invalid, opcode: 0
#      0x88	      0x1c	invalid, opcode: 0x1c
#      0x8c	      0x1c	invalid, opcode: 0x1c
#      0x90	0xffffff70	invalid, opcode: 0x70
#      0x94	      0x5c	invalid, opcode: 0x5c
#      0x98	0x200e4400	invalid, opcode: 0
#      0x9c	0x7f081144	invalid, opcode: 0x44
#      0xa0	   0x80c44	invalid, opcode: 0x44
#      0xa4	         0	invalid, opcode: 0
#      0xa8	         0	invalid, opcode: 0

