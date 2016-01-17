#Как компилировать программы с помощью gcc а потом запускать их на голом симуляторе или железе бех OC?

Короче, Bare metal в нашем случае.

Далее названия всех файлов соответвуют таким в этой папке, все действия повторены в скрипте run.sh, все происходит в bash-e

скомпилировать cpp файл riscv-gcc без startup кода, без билиотек
если несколько файлов используй скрипт для линкера
```
riscv64-unknown-linux-gnu-gcc -nostdlib -nostartfiles -o temp.elf test.cpp
```

если хочется просто посмореть инструкции
```
riscv64-unknown-linux-gnu-gcc -nostdlib -nostartfiles -S -o temp.s test.cpp
```

или уже в готовом elf:
```
riscv64-unknown-linux-gnu-objdump -d temp.elf 

temp.elf:     file format elf64-littleriscv


Disassembly of section .text:

00000000000110b0 <main>:
   110b0:	fe010113          	addi	sp,sp,-32
   110b4:	00813c23          	sd	s0,24(sp)
   110b8:	02010413          	addi	s0,sp,32
   110bc:	00100793          	li	a5,1
   110c0:	fef42423          	sw	a5,-24(s0)
   110c4:	00300793          	li	a5,3
   110c8:	fef42223          	sw	a5,-28(s0)
   110cc:	fe042623          	sw	zero,-20(s0)
   110d0:	fec42703          	lw	a4,-20(s0)
   110d4:	00300793          	li	a5,3
   110d8:	02e7c063          	blt	a5,a4,110f8 <main+0x48>
   110dc:	fe442783          	lw	a5,-28(s0)
   110e0:	0017879b          	addiw	a5,a5,1
   110e4:	fef42423          	sw	a5,-24(s0)
   110e8:	fec42783          	lw	a5,-20(s0)
   110ec:	0017879b          	addiw	a5,a5,1
   110f0:	fef42623          	sw	a5,-20(s0)
   110f4:	fddff06f          	j	110d0 <main+0x20>
   110f8:	fe842783          	lw	a5,-24(s0)
   110fc:	00078513          	mv	a0,a5
   11100:	01813403          	ld	s0,24(sp)
   11104:	02010113          	addi	sp,sp,32
   11108:	00008067          	ret

```

конвертировать elf в binary, все секции ложаться так как в живой программе
start address определяется нашей микросхемой, выставляется здесь
```
/home/jettatura/bin/riscv/bin/riscv64-unknown-linux-gnu-objcopy -O binary --set-start 0 temp.elf temp.bin
```

entry point - место откуда симулятор или железо будет выполнять инструкции, он же start address

теперь надо сделать образ памяти.
Для этого надо вставить temp.bin в начало куска нулей нужного размера. 
```
dd if=temp.bin of=$IMAGE_NAME bs=$IMAGE_SIZE conv=notrunc
```


Запускать в симуляторе
```
./sim -img  ../src/sim/bare_metal/flash.bin -i -e BE
```


BE - big endian, это издержки недопонимания от транслятора gipnocow в нашем случае. Этот вопрос надо решать. 

Дальше что получается.
Как видно не все инструкции у нас получилось сделать правильно.
Виноватых найдем. Однако кое что работает.

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
(isa-sim): d 0 100
dissasemble 100 words from address 0
         0	0xfe010113	  ADDI	 V0,  V0, 0xffffffe0
       0x4	  0x813c23	STORE-type invalid func3 field: opcode= #func3= 0x3
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
      0x30	  0x17879b	invalid, opcode: 0x1b
      0x34	0xfef42423	    SW	 T0, [ T7 + 0xffffffe8]
      0x38	0xfec42783	    LW	 T7, [ T0 + 0xffffffec]
      0x3c	  0x17879b	invalid, opcode: 0x1b
      0x40	0xfef42623	    SW	 T0, [ T7 + 0xffffffec]
      0x44	0xfddff06f	   JAL	ZERO, 0xffffffdc
      0x48	0xfe842783	    LW	 T7, [ T0 + 0xffffffe8]
      0x4c	   0x78513	  ADDI	 T2,  T7, 0
      0x50	 0x1813403	LOAD-type invalid func3 field: opcode= func3= 0x3
      0x54	 0x2010113	  ADDI	 V0,  V0, 0x20
      0x58	    0x8067	  JALR	ZERO, 0
      0x5c	0x3b031b01	invalid, opcode: 0x1
      0x60	      0x10	invalid, opcode: 0x10
      0x64	       0x1	invalid, opcode: 0x1
      0x68	0xffffffa4	invalid, opcode: 0x24
      0x6c	      0x2c	invalid, opcode: 0x2c
      0x70	      0x14	invalid, opcode: 0x14
      0x74	         0	invalid, opcode: 0
      0x78	  0x527a01	invalid, opcode: 0x1
      0x7c	 0x1010801	invalid, opcode: 0x1
      0x80	   0x20d1b	invalid, opcode: 0x1b
      0x84	         0	invalid, opcode: 0
      0x88	      0x1c	invalid, opcode: 0x1c
      0x8c	      0x1c	invalid, opcode: 0x1c
      0x90	0xffffff70	invalid, opcode: 0x70
      0x94	      0x5c	invalid, opcode: 0x5c
      0x98	0x200e4400	invalid, opcode: 0
      0x9c	0x7f081144	invalid, opcode: 0x44
      0xa0	   0x80c44	invalid, opcode: 0x44
      0xa4	         0	invalid, opcode: 0
      0xa8	         0	invalid, opcode: 0
      0xac	         0	invalid, opcode: 0
      0xb0	         0	invalid, opcode: 0
      0xb4	         0	invalid, opcode: 0
      0xb8	         0	invalid, opcode: 0
      0xbc	         0	invalid, opcode: 0
      0xc0	         0	invalid, opcode: 0
      0xc4	         0	invalid, opcode: 0
      0xc8	         0	invalid, opcode: 0
      0xcc	         0	invalid, opcode: 0
      0xd0	         0	invalid, opcode: 0
      0xd4	         0	invalid, opcode: 0
      0xd8	         0	invalid, opcode: 0
      0xdc	         0	invalid, opcode: 0
      0xe0	         0	invalid, opcode: 0
      0xe4	         0	invalid, opcode: 0
      0xe8	         0	invalid, opcode: 0
      0xec	         0	invalid, opcode: 0
      0xf0	         0	invalid, opcode: 0
      0xf4	         0	invalid, opcode: 0
      0xf8	         0	invalid, opcode: 0
      0xfc	         0	invalid, opcode: 0
     0x100	         0	invalid, opcode: 0
     0x104	         0	invalid, opcode: 0
     0x108	         0	invalid, opcode: 0
     0x10c	         0	invalid, opcode: 0
     0x110	         0	invalid, opcode: 0
     0x114	         0	invalid, opcode: 0
     0x118	         0	invalid, opcode: 0
     0x11c	         0	invalid, opcode: 0
     0x120	         0	invalid, opcode: 0
     0x124	         0	invalid, opcode: 0
     0x128	         0	invalid, opcode: 0
     0x12c	         0	invalid, opcode: 0
     0x130	         0	invalid, opcode: 0
     0x134	         0	invalid, opcode: 0
     0x138	         0	invalid, opcode: 0
     0x13c	         0	invalid, opcode: 0
     0x140	         0	invalid, opcode: 0
     0x144	         0	invalid, opcode: 0
     0x148	         0	invalid, opcode: 0
     0x14c	         0	invalid, opcode: 0
     0x150	         0	invalid, opcode: 0
     0x154	         0	invalid, opcode: 0
     0x158	         0	invalid, opcode: 0
     0x15c	         0	invalid, opcode: 0
     0x160	         0	invalid, opcode: 0
     0x164	         0	invalid, opcode: 0
     0x168	         0	invalid, opcode: 0
     0x16c	         0	invalid, opcode: 0
     0x170	         0	invalid, opcode: 0
     0x174	         0	invalid, opcode: 0
     0x178	         0	invalid, opcode: 0
     0x17c	         0	invalid, opcode: 0
     0x180	         0	invalid, opcode: 0
     0x184	         0	invalid, opcode: 0
     0x188	         0	invalid, opcode: 0
     0x18c	         0	invalid, opcode: 0
(isa-sim): 

```
 
