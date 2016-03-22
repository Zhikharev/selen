# selen-sim
risc-v isa simulator

Есть симуляторы [Spike](https://github.com/riscv/riscv-isa-sim) и [Qemu](https://github.com/riscv/riscv-qemu).
Однако интересно сделать свой.

####образы
Как компилировать образы с которыми работает симулятор с помощью [riscv-gcc](https://github.com/riscv/riscv-gnu-toolchain) описано в папке "bare metal"

####сборка

Linux:
```
cd директория-где-собирать
cmake директория-где-лежат-сорцы
make
```
надо обладать минимум GCC-4.9.2

в директории-где-собирать появится sim - симулятор.

####Интерактивный режим:

Можно пользоваться стрелками чтобы вызывать историю или редактировать, Enter вызовет последнюю набранную комманду:

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
(isa-sim): h
Avaible commands:
	                       help, h - print help.
	                 quit, exit, q - exit simulator
	                       load, l - load image to memory
	                    status, st - check simulator and program status
	                   tracing, tr - tracing settings
	           program-counter, pc - set/get program-counter
	                       step, s - make steps at simulator
	                      disas, d - disassemle
	                      print, p - print register or region of memory

	Use "help <command>" to get special command help
(isa-sim): h step
	                       step, s - arguments: <none>, [num]. Try to make num (1 if there is no arguments) steps at simulator

```
