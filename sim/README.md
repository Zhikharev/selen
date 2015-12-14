# selen-sim
risc-v isa simulator & disassembler

Официальные симуляторы Spike(https://github.com/riscv/riscv-isa-sim) и Qemu(https://github.com/riscv/riscv-qemu) очень крутые но пока нам не походят:
надо собирать toolchain (https://github.com/riscv/riscv-gnu-toolchain), после чего скомпилированные им исполняемые файлы надо правильно загружать в симулятор.

Этот симулятор&дизассемблер сделан специaльно для нашего транслятора (https://github.com/Zhikharev/selen/tree/master/assembler), он очень простой, однако поддерживает все инструкции предложенные в Isa.docx(13 декабря) 

Собирать надо cmake-ом, на Windows есть специальная программа, а в Linux:
```
cd директория-где-собирать
cmake директория-где-лежат-сорцы
make
```
в директории-где-собирать появятся два исполняемых файла: disas - дизассемлер, и sim - симулятор.
Также в ней должна появиться библиотекa libisa.so(Linux) или isa.dll(Windows) -  общая для дизассемблера и симулятора, 
из-за чего они воспринимают инструкции одинаково.

Пример использования:

дизассемблер,  файл out.bin взят из примера траслятора gipnocow:
```
jettatura@Jettatura-ubunty:-> ../../../build-sim/disas out.bin
too few arguments
Usage:	disasm <endianness>  <imagefile>

where:
	<endianness> - one of "LE" or "BE" - word endianness at imagefile
	<imagefile>  - binary executable

all parameters are strongly required
Example: 
 ./disasm LE image.bin
```
То есть надо передать аргумент порядка байт в словах:
```
jettatura@Jettatura-ubunty:-> ./disas LE ../src/assembler/out.bin
image ../src/assembler/out.bin size 84 b
endianness: LE
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


```

Image это образ памяти который загружается в симулятор, он должен целиком находится в файле.

симулятор:
```

jettatura@Jettatura-ubunty:-> ./sim

Error: too few arguments: 1
Usage:	sim <endianness> <adress-space-size> <steps> <entrypc> <imagefile>

where:
    <endianness> - one of "LE" or "BE" - word endianness at imagefile
    <adress-space-size>  -  address space byte size (dec)
    <steps>      - number of steps to perform (dec)
    <entrypc>    - PC start position(hex)
    <imagefile>  - binary executable

all parameters are strongly required
Example:
 ./sim LE 1024 25 0x45c image.bin
```

правильные аргументы:

```
jettatura@Jettatura-ubunty: pts/0: 11 files 2,3Mb -> ./sim LE 0xffff 25 0 ../src/assembler/out.bin
             CONFIG|        endianness: LE
             CONFIG|          mem size: 1
             CONFIG|             steps: 25
             CONFIG|          PC entry: 0
             CONFIG|             image: ../src/assembler/out.bin
Image ../src/assembler/out.bin loaded
Initial state dumped to : init_dump.txt
Start step...
Trace:
           0	    0x500813	  ADDI	 S0, ZERO, 0x5
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
        0x34	   0x1282223	    SW	 S0, [ S2 + 0x4]
        0x38	   0x12888b3	   ADD	 S1,  S1, S2
        0x3c	   0x1282423	    SW	 S0, [ S2 + 0x8]
        0x40	   0x12888b3	   ADD	 S1,  S1, S2
        0x44	   0x1282623	    SW	 S0, [ S2 + 0xc]
        0x48	   0x12888b3	   ADD	 S1,  S1, S2
        0x4c	   0x1282823	    SW	 S0, [ S2 + 0x10]
        0x50	   0x12888b3	   ADD	 S1,  S1, S2
        0x54	           0	invalid, opcode: 0

***************
SIMULATOR ERROR: illegal opcode 0, unable decode instruction: 0 at address 0x54
valid opcodes:
0x3	0x13	0x17	0x23	0x33	0x37	0x63	0x67	0x6f
***************



SUMMARY:

steps made: 21
State dumped to final_dump.txt


```

Здесь закончились инструкции, и вылезала и ошибка

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
