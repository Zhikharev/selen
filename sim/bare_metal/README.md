#Как компилировать программы с помощью gcc а потом запускать их на голом симуляторе или железе без OC?

скомпилировать cpp файл без startup кода, без билиотек
```
riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -o temp.elf test.cpp
```
флаг -m32 означает 32 битный RISCV

если надо просто посмотреть инструкции
```
riscv64-unknown-elf-gcc -m32 -nostdlib -nostartfiles -S -o temp.s test.cpp
```
 в готовом elf:
```
riscv64-unknown-elf-objdump -d temp.elf 

temp.elf:     file format elf32-littleriscv


Disassembly of section .text:

00010000 <main>:
   10000:	fe010113          	addi	sp,sp,-32
   10004:	00812e23          	sw	s0,28(sp)
   10008:	02010413          	addi	s0,sp,32
   1000c:	00100793          	li	a5,1
   10010:	fef42423          	sw	a5,-24(s0)
   10014:	00300793          	li	a5,3
   10018:	fef42223          	sw	a5,-28(s0)
   1001c:	fe042623          	sw	zero,-20(s0)
   10020:	fec42703          	lw	a4,-20(s0)
   10024:	00300793          	li	a5,3
   10028:	02e7c063          	blt	a5,a4,10048 <main+0x48>
   1002c:	fe442783          	lw	a5,-28(s0)
   10030:	00178793          	addi	a5,a5,1
   10034:	fef42423          	sw	a5,-24(s0)
   10038:	fec42783          	lw	a5,-20(s0)
   1003c:	00178793          	addi	a5,a5,1
   10040:	fef42623          	sw	a5,-20(s0)
   10044:	fddff06f          	j	10020 <main+0x20>
   10048:	fe842783          	lw	a5,-24(s0)
   1004c:	00078513          	mv	a0,a5
   10050:	01c12403          	lw	s0,28(sp)
   10054:	02010113          	addi	sp,sp,32
   10058:	00008067          	ret

```

конвертировать elf в binary
```
/home/jettatura/bin/riscv/bin/riscv64-unknown-elf-objcopy -O binary -S --set-start 0 temp.elf temp.bin
```
чтобы ссылки и метки не сбились надо было исрользовать скрипт линкера. Про это напишу потом.

теперь надо сделать образ памяти.
Для этого надо вставить temp.bin в начало куска нулей нужного размера. 
```
dd if=temp.bin of=flash.bin bs=4096 conv=notrunc
```

Запускать в симуляторе
```
./sim -img  ../src/sim/bare_metal/flash.bin -i -e BE
```

BE - big endian, это издержки недопонимания от транслятора gipnocow в нашем случае. Этот вопрос надо решать. 
```
Selen isa simulator 2015.
Parameters:
                  image file: ../src/sim/bare_metal/flash.bin
               state dump to: id.txt
               state dump to: fd.txt
                      regime: interactive
           Simulator config: 
                     tracing: on
                  endianness: BE
          address space size: 1222222 bytes
                    start pc: 0
                       steps: 0
Simulator at unteractive regime
(isa-sim): l
image ../src/sim/bare_metal/flash.bin was loaded to simulator memory at address 0
(isa-sim): d 0 30
dissasemble 30 words from address 0
         0	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
       0x4	  0x812e23	    SW	 V0, [ T0 + 0x1c]
       0x8	 0x2010413	  ADDI	 T0,  V0, 0x20
       0xc	  0x100793	  ADDI	 T7, ZERO, 0x1
      0x10	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
      0x14	  0x300793	  ADDI	 T7, ZERO, 0x3
      0x18	0xfef42223	    SW	 T0, [ T7 + 0xffffffe4]
      0x1c	0xfe042623	    SW	 T0, [ZERO + 0xffffffec]
      0x20	0xfec42703	    LW	 T6, [ T0 + 0xffffffec]
      0x24	  0x300793	  ADDI	 T7, ZERO, 0x3
      0x28	 0x2e7c063	   BLT	 T7,  T6, [0x20]
      0x2c	0xfe442783	    LW	 T7, [ T0 + 0xffffffe4]
      0x30	  0x178793	  ADDI	 T7,  T7, 0x1
      0x34	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
      0x38	0xfec42783	    LW	 T7, [ T0 + 0xffffffec]
      0x3c	  0x178793	  ADDI	 T7,  T7, 0x1
      0x40	0xfef42623	    SW	 T0, [ T7 + 0xffffffec]
      0x44	0xfddff06f	   JAL	ZERO, 0xffffffdc
      0x48	0xfe842783	    LW	 T7, [ T0 + 0xffffffe8]
      0x4c	   0x78513	  ADDI	 T2,  T7, 0
      0x50	 0x1c12403	    LW	 T0, [ V0 + 0x1c]
      0x54	 0x2010113	  ADDI	 V0,  V0, 0x20
      0x58	    0x8067	  JALR	ZERO, 0
      0x5c	      0x10	invalid, opcode: 0x10
      0x60	         0	invalid, opcode: 0
      0x64	  0x527a01	invalid, opcode: 0x1
      0x68	 0x1010401	invalid, opcode: 0x1
      0x6c	   0x20d1b	invalid, opcode: 0x1b
      0x70	      0x18	invalid, opcode: 0x18
      0x74	      0x18	invalid, opcode: 0x18
(isa-sim): 

```
 
