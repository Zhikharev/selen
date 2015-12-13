# selen-sim
risc-v isa simulator & disassembler

Официальные симуляторы Spike(https://github.com/riscv/riscv-isa-sim) и Qemu(https://github.com/riscv/riscv-qemu) очень крутые но пока нам не походят:
надо собирать toolchain (https://github.com/riscv/riscv-gnu-toolchain), плюс надо возиться со скриптами линкера gcc, чтобы правильно расположить секции бинарника.

Этот симулятор&дизассемблер сделан специaльно для нашего транслятора (https://github.com/Zhikharev/selen/tree/master/assembler), он очень простой, однако поддерживает все инструкции предложенные в Isa.docx(13 декабря) 

Собирать его надо cmake-ом, на Windows есть программа с гуем, вот, в Linux:
```
cd some-build-dir
cmake path-to-simulator-src-dir
make
```
в директории где это было сделано появится два исполняемых файла: disas - дизассемлер, и sim - симулятор.
Также в ней будет библиотекa libisa.so(Linux) или isa.dll(Windows) -  общая для дизассемблера и симулятора, 
благодаря чему они видят инструкции одинаково.

Я предполагаю засунуть эти штуки в питоновские скрипты, поэтому у них довольно много аргументов передается через командную строку. 

вот дизассемблер, out.bin -файл из примера траслятора gipnocow:
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
поэтому надо передать аргумент порядка байт в словах, (наш транслятор кладет инструкции в Big Endian):
```
../../../build-sim/disas BE out.bin
image out.bin size 84 b
endianness: BE
         0	  0x500813	ADDI	S0, ZERO, 0x5
       0x4	  0xc81813	SLLI	S0, S0, 0xc
       0x8	  0x500413	ADDI	T0, ZERO, 0x5
       0xc	  0x300493	ADDI	T1, ZERO, 0x3
      0x10	  0x600513	ADDI	T2, ZERO, 0x6
      0x14	  0x9405b3	ADD	T3, T0, T1
      0x18	  0xb50633	ADD	T4, T2, T3
      0x1c	   0x82403	LW	T0, [S0 + 0]
      0x20	  0x482483	LW	T1, [S0 + 0x4]
      0x24	  0x882503	LW	T2, [S0 + 0x8]
      0x28	  0xc82583	LW	T3, [S0 + 0xc]
      0x2c	 0x1082603	LW	T4, [S0 + 0x10]
      0x30	 0x1182023	SW	S0, [S1 + 0]
      0x34	 0x1282223	SW	S0, [S2 + 0x4]
      0x38	 0x12888b3	ADD	S1, S1, S2
      0x3c	 0x1282423	SW	S0, [S2 + 0x8]
      0x40	 0x12888b3	ADD	S1, S1, S2
      0x44	 0x1282623	SW	S0, [S2 + 0xc]
      0x48	 0x12888b3	ADD	S1, S1, S2
      0x4c	 0x1282823	SW	S0, [S2 + 0x10]
      0x50	 0x12888b3	ADD	S1, S1, S2

```

все верно. инструкции JAL нет в образе.

Image это образ памяти который загружается в симулятор, он целиком должен находится в файле.
В перспективе надо сделать загрузчик на питоне который превращает исполняемый файл с секциями в образ.
Но разве исполняемый файл с секциями будет загружаться в модель RTL?
Я бы мог поддержать это в симуляторе, сделать его внутренним,  но там где я просто увеличу массив С++, где вы возьмете эту память в RTL?
Образы должны быть одинаковы, и об этом должен думать внешний красивый загрузчик.

так вот, тот же файл out.bin, симулятор:
```
jettatura@Jettatura-ubunty: pts/0: 5 files 28Kb -> ../../../build-sim/sim BE 10 0 out.bin
             CONFIG|        endianness: BE
             CONFIG|             steps: 10
             CONFIG|          PC entry: 0
             CONFIG|             image: out.bin
image out.bin loaded
initial memory layout:

endianness: BE
         0 | 0x500813
       0x4 | 0xc81813
       0x8 | 0x500413
       0xc | 0x300493
      0x10 | 0x600513
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

start step...
Trace: 
0x4	0x500813	ADDI	S0, ZERO, 0x5
0x8	0xc81813	SLLI	S0, S0, 0xc
0xc	0x500413	ADDI	T0, ZERO, 0x5
0x10	0x300493	ADDI	T1, ZERO, 0x3
0x14	0x600513	ADDI	T2, ZERO, 0x6
0x18	0x9405b3	ADD	T3, T0, T1
0x1c	0xb50633	ADD	T4, T2, T3

***************
SIMULATOR ERROR: memory read: address refers to position out of memory: 0x5000, avaible memory size: 0x54
***************



SUMMARY:

steps made: 7
State dumped to dump.txt
```

Здесь ошибка чтения из памяти, тк образ слишком маленький. 

Образ памяти и регистровый файл после завершения находятся в файле dump.txt:

```
PC:	0x1c
ZERO:	0
AT:	0
V0:	0
V1:	0
A0:	0
A1:	0
A2:	0
A3:	0
T0:	0x5
T1:	0x3
T2:	0x6
T3:	0x8
T4:	0xe
T5:	0
T6:	0
T7:	0
S0:	0x5000
S1:	0
S2:	0
S3:	0
S4:	0
S5:	0
S6:	0
S7:	0
T8:	0
T9:	0
K0:	0
K1:	0
GP:	0
SP:	0
FP:	0
RA:	0
endianness: BE
         0 | 0x500813
       0x4 | 0xc81813
       0x8 | 0x500413
       0xc | 0x300493
      0x10 | 0x600513
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
```
