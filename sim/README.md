# selen-sim
risc-v isa simulator & disassembler

Есть симуляторы Spike(https://github.com/riscv/riscv-isa-sim) и Qemu(https://github.com/riscv/riscv-qemu).
Но интересно сделать свой.

Этот симулятор сделан специaльно для нашего транслятора (https://github.com/Zhikharev/selen/tree/master/assembler), он очень простой, однако поддерживает все инструкции предложенные в Isa.docx(13 декабря) 

Собирать cmake-ом в Linux:
```
cd директория-где-собирать
cmake директория-где-лежат-сорцы
make
```

в директории-где-собирать появятся два исполняемых файла: disas - дизассемлер, и sim - симулятор.
Также в ней должна появиться библиотекa libisa.so.

Пример использования:

файл out.bin взят из примера траслятора gipnocow.

Дизассемблер:
пока устарел, его функции теперь в интерактивном режиме симулятора. Позже его наверное удалю.

Симулятор:

```
./sim -h

Selen isa simulator 2015.Options:
                   --endianess,   -e - word endianness at imagefile, LE -little endian, BE - big endian
                       --image, -img - path to memory image file
                  --final-dump,  -fd - state will dumped here after execution, default fd.txt
                        --help,   -h - show help and exit
             --program-counter,  -pc - program-counter start value(hex with 0x prefix)
           --adress-space-size,  -as - address space byte size (dec)
                       --steps,   -s - number of steps to perform (dec)
                       --quiet,   -q - be quiet
                  --no-tracing,  -nt - disable tracing (tracing is enabled by default)
                 --interactive,   -i - run in interactive regime (simple regime by default)
```

Image это образ памяти который загружается в симулятор, он должен целиком находится в файле.

Интерактивный режим:
```
./sim -img  ../src/assembler/out.bin -as 1222222 -i
Selen isa simulator 2015.
Parameters:
                  image file: ../src/assembler/out.bin
               state dump to: id.txt
               state dump to: fd.txt
                      regime: interactive
           Simulator config: 
                     tracing: on
                  endianness: LE
          address space size: 1222222 bytes
                    start pc: 0
                       steps: 0
Simulator at unteractive regime
(isa-sim): help
Avaible commands:
	quit, exit, q - exit simulator
	help, h - print help
	load, l [filename] [address] - load image from "filename"(may be omitted if was specified by command line) to memory at address (default 0)
	status, st - check simulator and program status
	tracing, tr [on, off, yes, no] - turn on/off step tracing (to std::cout)
	program-counter, pc [address] - get program-counter without address argument, set if address exists
	step, s [num] - make num (0 if num arg missed) steps at simulator
	disas, d <address> [num] - disassemle num words(default 10) from address at memory

(isa-sim): l
image ../src/assembler/out.bin was loaded to simulator memory at address 0
(isa-sim): load ../src/assembler/out.bin 0x64
image ../src/assembler/out.bin was loaded to simulator memory at address 0x64
(isa-sim): d 0 32
dissasemble 32 words from address 0
         0	  0x500813	  ADDI	 S0, ZERO, 0x5
       0x4	  0xc81813	  SLLI	 S0,  S0, 0xc
       0x8	  0x500413	  ADDI	 T0, ZERO, 0x5
       0xc	  0x300493	  ADDI	 T1, ZERO, 0x3
      0x10	  0x600513	  ADDI	 T2, ZERO, 0x6
      0x14	  0x9405b3	   ADD	 T3,  T0, T1
      0x18	  0xb50633	   ADD	 T4,  T2, T3
      0x1c	   0x82403	    LW	 T0, [ S0 + 0]
      0x20	  0x482483	    LW	 T1, [ S0 + 0x4]
      0x24	  0x882503	    LW	 T2, [ S0 + 0x8]
      0x28	  0xc82583	    LW	 T3, [ S0 + 0xc]
      0x2c	 0x1082603	    LW	 T4, [ S0 + 0x10]
      0x30	 0x1182023	    SW	 S0, [ S1 + 0]
      0x34	 0x1282223	    SW	 S0, [ S2 + 0x4]
      0x38	 0x12888b3	   ADD	 S1,  S1, S2
      0x3c	 0x1282423	    SW	 S0, [ S2 + 0x8]
      0x40	 0x12888b3	   ADD	 S1,  S1, S2
      0x44	 0x1282623	    SW	 S0, [ S2 + 0xc]
      0x48	 0x12888b3	   ADD	 S1,  S1, S2
      0x4c	 0x1282823	    SW	 S0, [ S2 + 0x10]
      0x50	 0x12888b3	   ADD	 S1,  S1, S2
      0x54	         0	invalid, opcode: 0
      0x58	         0	invalid, opcode: 0
      0x5c	         0	invalid, opcode: 0
      0x60	         0	invalid, opcode: 0
      0x64	  0x500813	  ADDI	 S0, ZERO, 0x5
      0x68	  0xc81813	  SLLI	 S0,  S0, 0xc
      0x6c	  0x500413	  ADDI	 T0, ZERO, 0x5
      0x70	  0x300493	  ADDI	 T1, ZERO, 0x3
      0x74	  0x600513	  ADDI	 T2, ZERO, 0x6
      0x78	  0x9405b3	   ADD	 T3,  T0, T1
      0x7c	  0xb50633	   ADD	 T4,  T2, T3
(isa-sim): pc 0x4
current pc: 0x4
(isa-sim): trace on
unknown command: trace on
(isa-sim): tracing on
tracing: on
(isa-sim): s 12
start 12 step from 0x4
Trace: 
         0x4	    0xc81813	  SLLI	 S0,  S0, 0xc
         0x8	    0x500413	  ADDI	 T0, ZERO, 0x5
         0xc	    0x300493	  ADDI	 T1, ZERO, 0x3
        0x10	    0x600513	  ADDI	 T2, ZERO, 0x6
        0x14	    0x9405b3	   ADD	 T3,  T0, T1
        0x18	    0xb50633	   ADD	 T4,  T2, T3
        0x1c	     0x82403	    LW	 T0, [ S0 + 0]
        0x20	    0x482483	    LW	 T1, [ S0 + 0x4]
        0x24	    0x882503	    LW	 T2, [ S0 + 0x8]
        0x28	    0xc82583	    LW	 T3, [ S0 + 0xc]
        0x2c	   0x1082603	    LW	 T4, [ S0 + 0x10]
        0x30	   0x1182023	    SW	 S0, [ S1 + 0]
steps performed 12, current pc 0x34
(isa-sim): q

```

Добавлять новые команды просто, поэтому он будет прирастать.


После завершения симулятора образ памяти и регистры сбрасываются в файл final_dump.txt:

```
PC:     0x54
ZERO:   0
AT:     0
V0:     0
V1:     0
A0:     0
A1:     0
A2:     0
A3:     0
T0:     0
T1:     0
T2:     0
T3:     0
T4:     0
T5:     0
T6:     0
T7:     0
S0:     0x5000
S1:     0
S2:     0
S3:     0
S4:     0
S5:     0
S6:     0
S7:     0
T8:     0
T9:     0
K0:     0
K1:     0
GP:     0
SP:     0
FP:     0
RA:     0
endianness: LE
         0 | 0x5000
       0x4 | 0x5000
       0x8 | 0x5000
       0xc | 0x5000
      0x10 | 0x5000
      0x14 | 0x9405b3
      0x18 | 0xb50633
      0x1c | 0x82403
      0x20 | 0x482483
      0x24 | 0x882503
      0x28 | 0xc82583
      0x2c | 0x1082603
      0x30 | 0x1182023
      0x34 | 0x1282223
      0x38 | 0x12888b3
      0x3c | 0x1282423
      0x40 | 0x12888b3
      0x44 | 0x1282623
      0x48 | 0x12888b3
      0x4c | 0x1282823
      0x50 | 0x12888b3
      0x54 | 0
      0x58 | 0
      0x5c | 0
      0x60 | 0
      ...
```


