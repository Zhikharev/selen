#Как компилировать программы с помощью gcc а потом запускать их в симуляторе?


есть [riscv-gcc](https://github.com/riscv/riscv-gnu-toolchain) собранный с опцией --enable-multilib.

Задача следующая:
 - Скомпилировать файл prog.cpp и запустить его в симуляторе.


В папке предлагается Makefile где это происходит.

Действия:

1) скомпилировать cpp файл в объектник
 
``` cpp
 int main()
{
	volatile int a=1, b =3;
	for (int i=0; i< 4; i++)	
		a= b+1; 
	return a;
}
```
```
riscv64-unknown-elf-gcc -m32 -c -o prog.o prog.cpp
```
флаг -m32 означает 32 битный RISCV

если надо посмотреть инструкции
```
riscv64-unknown-elf-gcc -m32 -S -o prog.s prog.cpp
```
 ```asm
 	.file	"prog.cpp"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	add	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	s0,28(sp)
	.cfi_offset 8, -4
	add	s0,sp,32
	.cfi_def_cfa 8, 0
	li	a5,1
	sw	a5,-24(s0)
	li	a5,3
	sw	a5,-28(s0)
	sw	zero,-20(s0)
.L3:
	lw	a4,-20(s0)
	li	a5,3
	bgt	a4,a5,.L2
	lw	a5,-28(s0)
	add	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	add	a5,a5,1
	sw	a5,-20(s0)
	j	.L3
.L2:
	lw	a5,-24(s0)
	mv	a0,a5
	lw	s0,28(sp)
	add	sp,sp,32
	jr	ra
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
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
Символы _entry, и stack_top передаются линкеру, их встретим в скрипте линкера, main находится в prog.cpp. Линкер заменит их на адреса.

3) Слинковать объектники и получить исполняемый файл.
В [riscv-test](https://github.com/riscv/riscv-tests/tree/master/benchmarks/common) можно найти скрипт линкера и стратап код.
Секцию кода там располагают по адресу 0x100. А в [stackoverflow](http://stackoverflow.com/questions/31390127/how-can-i-compile-c-code-to-get-a-bare-metal-skeleton-of-a-minimal-risc-v-assemb) 
говорится что golden model([Spike](https://github.com/riscv/riscv-isa-sim)) стартует с 0x200.
Мы будем пока класть по 0x0, потому что мы можем стартовать откуда хотим:

```
ENTRY(_entry)
SECTIONS
{
 . = 0x0;
 .startup . : { startup.o(.text) }
 .text : { *(.text) }
 .data : { *(.data) }
 .bss : { *(.bss COMMON) }
 . = ALIGN(8);
 . = . + 0x1000; /* 4kB of stack memory */
 stack_top = .;
}
```

Линкуем:

```
riscv64-unknown-elf-ld -melf32lriscv -T linker.ld startup.o prog.o -o prog.elf
```
-melf32lriscv скажет линкеру что надо использовать ABI elf32lriscv

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
dd if=prog.bin of=flash.bin bs=65536 conv=notrunc
```
размер 65536 байт, главное чтобы больше чем стек, чтобы все уместилось.

*Готово, flash.bin это наш образ!*

####Запускать в симуляторе

flash.bin  можно было запустить в Spike или QEMU если прописать в скрипте правильный адрес начала.
В нашем симуляторе:
```
./sim -img ./flash.bin
```

Интерактивный режим:
```
~/projects/selen/build
jettatura@Jettatura-ubunty: pts/9: 17 files 8,9Mb -> ./sim -img ../src/sim/bare_metal/flash.bin  -i -as 65536
Selen isa simulator 2015.
Parameters:
                  image file: ../src/sim/bare_metal/flash.bin
               state dump to: id.txt
               state dump to: fd.txt
                      regime: interactive
           Simulator config:
                     tracing: on
                  endianness: LE
          address space size: 65536 bytes
                    start pc: 0
                       steps: 0
Simulator at interactive regime
(isa-sim): l
image ../src/sim/bare_metal/flash.bin was loaded to simulator memory at address 0
(isa-sim): d 0
dissasemble 10 words from address 0
         0	    0x1117	 AUIPC	 sp, 0x1000
       0x4	 0x9810113	  ADDI	 sp,  sp, 152
       0x8	  0x40006f	   JAL	zero, 0x4
       0xc	0xfe010113	  ADDI	 sp,  sp, -32
      0x10	  0x812e23	    SW	 sp, [ s0 + 0x1c]
      0x14	 0x2010413	  ADDI	 s0,  sp, 32
      0x18	  0x100793	  ADDI	 a5, zero, 1
      0x1c	0xfef42423	    SW	 s0, [ a5 + 0xffffffe8]
      0x20	  0x300793	  ADDI	 a5, zero, 3
      0x24	0xfef42223	    SW	 s0, [ a5 + 0xffffffe4]
(isa-sim): s 10
start 10 step from 0
         0:	[memory]       READ ; size 4 bytes; addr 0x00000000; value 0x11170000
         1:	[fetch]        	-|-->	0x00000000	 0x11170000	 AUIPC	 sp, 0x1000
         2:	[register]     WRITE; id 2 -> sp; value  0x10000000; diff 4096 (0x1000)
         3:	[memory]       READ ; size 4 bytes; addr 0x40000000; value 0x98101130
         4:	[fetch]        	-|-->	0x40000000	 0x98101130	  ADDI	 sp,  sp, 152
         5:	[register]     READ ; id 2 -> sp; value  0x10000000
         6:	[register]     WRITE; id 2 -> sp; value  0x10980000; diff 152 (0x98)
         7:	[memory]       READ ; size 4 bytes; addr 0x80000000; value 0x40006f00
         8:	[fetch]        	-|-->	0x80000000	 0x40006f00	   JAL	zero, 0x4
         9:	[register]     WRITE; id 0 -> zero; value  0x80000000; diff 8 (0x8)
        10:	[memory]       READ ; size 4 bytes; addr 0xc0000000; value 0xfe010113
        11:	[fetch]        	-|-->	0xc0000000	 0xfe010113	  ADDI	 sp,  sp, -32
        12:	[register]     READ ; id 2 -> sp; value  0x10980000
        13:	[register]     WRITE; id 2 -> sp; value  0x10780000; diff -32 (0xffffffe0)
        14:	[memory]       READ ; size 4 bytes; addr 0x10000000; value 0x812e2300
        15:	[fetch]        	-|-->	0x10000000	 0x812e2300	    SW	 sp, [ s0 + 0x1c]
        16:	[register]     READ ; id 8 -> s0; value  0x00000000
        17:	[register]     READ ; id 2 -> sp; value  0x10780000
        18:	[memory]       WRITE; size 4 bytes; addr 0x10940000; value 0x00000000
        19:	[memory]       READ ; size 4 bytes; addr 0x14000000; value 0x20104130
        20:	[fetch]        	-|-->	0x14000000	 0x20104130	  ADDI	 s0,  sp, 32
        21:	[register]     READ ; id 2 -> sp; value  0x10780000
        22:	[register]     WRITE; id 8 -> s0; value  0x10980000; diff 4248 (0x1098)
        23:	[memory]       READ ; size 4 bytes; addr 0x18000000; value 0x10079300
        24:	[fetch]        	-|-->	0x18000000	 0x10079300	  ADDI	 a5, zero, 1
        25:	[register]     READ ; id 0 -> zero; value  0x00000000
        26:	[register]     WRITE; id 15 -> a5; value  0x10000000; diff 1 (0x1)
        27:	[memory]       READ ; size 4 bytes; addr 0x1c000000; value 0xfef42423
        28:	[fetch]        	-|-->	0x1c000000	 0xfef42423	    SW	 s0, [ a5 + 0xffffffe8]
        29:	[register]     READ ; id 15 -> a5; value  0x10000000
        30:	[register]     READ ; id 8 -> s0; value  0x10980000
        31:	[memory]       WRITE; size 4 bytes; addr 0x10800000; value 0x10000000
        32:	[memory]       READ ; size 4 bytes; addr 0x20000000; value 0x30079300
        33:	[fetch]        	-|-->	0x20000000	 0x30079300	  ADDI	 a5, zero, 3
        34:	[register]     READ ; id 0 -> zero; value  0x00000000
        35:	[register]     WRITE; id 15 -> a5; value  0x30000000; diff 2 (0x2)
        36:	[memory]       READ ; size 4 bytes; addr 0x24000000; value 0xfef42223
        37:	[fetch]        	-|-->	0x24000000	 0xfef42223	    SW	 s0, [ a5 + 0xffffffe4]
        38:	[register]     READ ; id 15 -> a5; value  0x30000000
        39:	[register]     READ ; id 8 -> s0; value  0x10980000
        40:	[memory]       WRITE; size 4 bytes; addr 0x107c0000; value 0x30000000
steps performed 10, current pc 0x28
(isa-sim): p reg
PC:	0x28
zero:	0
ra:	0
sp:	0x1078
gp:	0
tp:	0
t0:	0
t1:	0
t2:	0
s0:	0x1098
s1:	0
a0:	0
a1:	0
a2:	0
a3:	0
a4:	0
a5:	0x3
a6:	0
a7:	0
s2:	0
s3:	0
s4:	0
s5:	0
s6:	0
s7:	0
s8:	0
s9:	0
s10:	0
s11:	0
t3:	0
t4:	0
t5:	0
t6:	0


```
