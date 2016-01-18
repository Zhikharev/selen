#Как компилировать программы с помощью gcc а потом запускать их на голом симуляторе или железе без OC?


есть [riscv-gcc](https://github.com/riscv/riscv-gnu-toolchain) собранный с опцией --enable-multilib.

Задача следующая:
	Скомпилироать файл prog.cpp и запустить его в симуляторе.




В папке предлагается Makefile где это происходит.

Действия:

1) скомпилировать cpp файл в объектник
 
```
riscv64-unknown-elf-gcc -m32 -c -o prog.o prog.cpp
```
флаг -m32 означает 32 битный RISCV

если надо посмотреть инструкции (главное чтобы были те что у нас пока есть)
```
riscv64-unknown-elf-gcc -m32 -S -o prog.s prog.cpp
```
 
2) собрать стартап код (файл startup.s) в объектник
```asm
.global _entry
_entry:
 la sp, stack_top
 j main
```
командой
```
riscv64-unknown-elf-as -m32 startup.s -g -o startup.o
```
Символы _entry, main и stack_top передаются линкеру, их встретим в скрипте линкера.

3) Слинковать объектники и получить исполняемый файл.
В (riscv-test)[https://github.com/riscv/riscv-tests/tree/master/benchmarks/common] можно найти скрипт линкера и стратап код.
Секцию кода там располагают по адресу 0x100. А в [stackoverflow](http://stackoverflow.com/questions/31390127/how-can-i-compile-c-code-to-get-a-bare-metal-skeleton-of-a-minimal-risc-v-assemb) 
говорится что golden model(Spike) стартует 0x200.
Мы будем пока класть по 0x0, потому что у нас стартовать мы можем откуда хотим.

Линкуем:

```
riscv64-unknown-elf-ld -melf32lriscv -T linker.ld startup.o prog.o -o prog.elf
```

Посмотреть инструкции в готовом elf командой:
```
riscv64-unknown-elf-objdump -d prog.elf 
prog.elf:     file format elf32-littleriscv


Disassembly of section .startup:

00000000 <_entry>:
   0:	00001117          	auipc	sp,0x1
   4:	09810113          	addi	sp,sp,152 # 1098 <stack_top>
   8:	0040006f          	j	c <main>

Disassembly of section .text:

0000000c <main>:
   c:	fe010113          	addi	sp,sp,-32
  10:	00812e23          	sw	s0,28(sp)
  14:	02010413          	addi	s0,sp,32
  18:	00100793          	li	a5,1
  1c:	fef42423          	sw	a5,-24(s0)
  20:	00300793          	li	a5,3
  24:	fef42223          	sw	a5,-28(s0)
  28:	fe042623          	sw	zero,-20(s0)
  2c:	fec42703          	lw	a4,-20(s0)
  30:	00300793          	li	a5,3
  34:	02e7c063          	blt	a5,a4,54 <main+0x48>
  38:	fe442783          	lw	a5,-28(s0)
  3c:	00178793          	addi	a5,a5,1
  40:	fef42423          	sw	a5,-24(s0)
  44:	fec42783          	lw	a5,-20(s0)
  48:	00178793          	addi	a5,a5,1
  4c:	fef42623          	sw	a5,-20(s0)
  50:	fddff06f          	j	2c <main+0x20>
  54:	fe842783          	lw	a5,-24(s0)
  58:	00078513          	mv	a0,a5
  5c:	01c12403          	lw	s0,28(sp)
  60:	02010113          	addi	sp,sp,32
  64:	00008067          	ret


```
4) конвертировать elf в binary
```
riscv64-unknown-elf-objcopy  -O binary -S --set-start 0 prog.elf prog.bin
```
секции лягут по адресам указанным в линкере.

5) теперь надо сделать образ памяти.

Для этого надо вставить binary в начало куска нулей нужного размера. 

```
dd if=prog.bin of=flash.bin bs=4096 conv=notrunc
```

*Готово, flash.bin это наш образ!*

####Запускать в симуляторе
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
          address space size: 1024 bytes
                    start pc: 0
                       steps: 0
Simulator at interactive regime
(isa-sim): l
image ../src/sim/bare_metal/flash.bin was loaded to simulator memory at address 0
(isa-sim): d 0
dissasemble 10 words from address 0
         0	    0x1117	 AUIPC V0, 0x1000
       0x4	 0x9810113	  ADDI	 V0,  V0, 0x98
       0x8	  0x40006f	   JAL	ZERO, 0x4
       0xc	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
      0x10	  0x812e23	    SW	 V0, [ T0 + 0x1c]
      0x14	 0x2010413	  ADDI	 T0,  V0, 0x20
      0x18	  0x100793	  ADDI	 T7, ZERO, 0x1
      0x1c	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
      0x20	  0x300793	  ADDI	 T7, ZERO, 0x3
      0x24	0xfef42223	    SW	 T0, [ T7 + 0xffffffe4]
(isa-sim): s
start 1 step from 0
Trace: 
           0	      0x1117	 AUIPC V0, 0x1000
steps performed 1, current pc 0x4
(isa-sim): s
start 1 step from 0x4
Trace: 
         0x4	   0x9810113	  ADDI	 V0,  V0, 0x98
steps performed 1, current pc 0x8
(isa-sim): s
start 1 step from 0x8
Trace: 
         0x8	    0x40006f	   JAL	ZERO, 0x4
steps performed 1, current pc 0xc
(isa-sim): s
start 1 step from 0xc
Trace: 
         0xc	  0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
steps performed 1, current pc 0x10
(isa-sim): s
start 1 step from 0x10
Trace: 
        0x10	    0x812e23	    SW	 V0, [ T0 + 0x1c]
steps performed 1, current pc 0x14
(isa-sim): s
start 1 step from 0x14
Trace: 
        0x14	   0x2010413	  ADDI	 T0,  V0, 0x20
steps performed 1, current pc 0x18
(isa-sim): s
start 1 step from 0x18
Trace: 
        0x18	    0x100793	  ADDI	 T7, ZERO, 0x1
steps performed 1, current pc 0x1c
(isa-sim): s
start 1 step from 0x1c
Trace: 
        0x1c	      0x1078	invalid, opcode: 0x78

***************
SIMULATOR ERROR: illegal opcode 0x78, unable decode instruction: 0x1078 at address 0x1c
valid opcodes:
0x3	0x13	0x17	0x23	0x33	0x37	0x63	0x67	0x6f	
***************

steps performed 0, current pc 0x1c
(isa-sim): d 0
dissasemble 10 words from address 0
         0	    0x1117	 AUIPC V0, 0x1000
       0x4	 0x9810113	  ADDI	 V0,  V0, 0x98
       0x8	  0x40006f	   JAL	ZERO, 0x4
       0xc	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
      0x10	  0x812e23	    SW	 V0, [ T0 + 0x1c]
      0x14	 0x2010413	  ADDI	 T0,  V0, 0x20
      0x18	  0x100793	  ADDI	 T7, ZERO, 0x1
      0x1c	    0x1078	invalid, opcode: 0x78
      0x20	  0x300793	  ADDI	 T7, ZERO, 0x3
      0x24	0xfef42223	    SW	 T0, [ T7 + 0xffffffe4]
(isa-sim): 

```
 Кое что зашагало, однако программа поменяла сама себя во время выполнения. Это startup code не очень. Это детали.
