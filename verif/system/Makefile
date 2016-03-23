BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
TOP=selen_tb_top

AS 		  = riscv32-unknown-elf-as
OBJCOPY = riscv32-unknown-elf-objcopy

include $(BENCH_HOME)/../../rtl/top/Makefrag
include $(BENCH_HOME)/../tools/Makefile.global
include $(BENCH_HOME)/Makefrag

rom_image:
	$(AS) $(GIT_HOME)/firmware/sl_ram_jmp.c -o sl_ram_jmp.elf
	$(OBJCOPY) -O binary sl_ram_jmp.elf sl_ram_jmp.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 sl_ram_jmp.bin rom_bge.bin
	rm -f rom_image.v
	xxd -c 4 -p rom_bge.bin >> rom_image.v

build: analyze elaborate

sim:
	./simv -l test.log $(RUN_OPTS) $(SIM_OPTS)

