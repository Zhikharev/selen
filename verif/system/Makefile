BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
TOP=selen_tb_top

AS 		  = riscv32-unknown-elf-as
CCX     = riscv32-unknown-elf-gcc
LD      = riscv32-unknown-elf-ld
OBJCOPY = riscv32-unknown-elf-objcopy
STRIP   = riscv32-unknown-elf-strip

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

sl_gpio_led_on:
	$(AS) $(GIT_HOME)/firmware/sl_gpio_led_on.c -o sl_gpio_led_on.elf
	$(OBJCOPY) -O binary sl_gpio_led_on.elf sl_gpio_led_on.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 sl_gpio_led_on.bin rom_bge.bin
	rm -f rom_image.v
	xxd -c 4 -p rom_bge.bin >> rom_image.v

sl_gpio_led_blink:
	$(AS) $(GIT_HOME)/firmware/sandbox/startup.s -o startup.o
	$(CCX) -c $(GIT_HOME)/firmware/sandbox/blink.c  -nostdlib -O2 -o blink.o
	$(LD) -T $(GIT_HOME)/firmware/sandbox/blink.ld blink.o -o blink.elf
	$(STRIP) blink.elf -o blink.elf.strip
	$(OBJCOPY) -O binary blink.elf blink.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 blink.bin ram_bge.bin
	rm -f ram_image.v
	xxd -c 4 -p ram_bge.bin >> ram_image.v

sl_gpio_led_blink_rom:
	$(AS) $(GIT_HOME)/firmware/sandbox/startup.s -o startup.o
	$(CCX) -c $(GIT_HOME)/firmware/sandbox/blink.c  -nostdlib -O2 -o blink.o
	$(LD) -T $(GIT_HOME)/firmware/sandbox/blink.proto.ld blink.o -o blink.elf
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 blink.elf blink_bge.elf
	rm -f blink_rom.v
	xxd -c 4 -p blink_bge.elf >> blink_rom.v
	rm -f rom_image.v
	cp blink_rom.v rom_image.v

sl_ram_jmp:
	$(AS) $(GIT_HOME)/firmware/sl_ram_jmp.c -o sl_ram_jmp.elf
	$(OBJCOPY) -O binary sl_ram_jmp.elf sl_ram_jmp.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 sl_ram_jmp.bin rom_bge.bin
	rm -f rom_image.v
	xxd -c 4 -p rom_bge.bin >> rom_image.v

debug_api:
	$(AS) $(GIT_HOME)/firmware/sandbox/startup.s -o startup.o
	$(CCX) -c $(GIT_HOME)/verif/system/tests/test_api.c -nostdlib -O2 -o test_api.o
	$(CCX) -c $(GIT_HOME)/verif/system/tests/debug_api.c -nostdlib -O2 -o debug_api.o
	$(LD) -T $(GIT_HOME)/firmware/sandbox/blink.ld test_api.o debug_api.o -o debug_api.elf
	$(OBJCOPY) -O binary debug_api.elf debug_api.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 debug_api.bin ram_bge.bin
	rm -f ram_image.v
	xxd -c 4 -p ram_bge.bin >> ram_image.v

sl_spi:
	$(AS) $(GIT_HOME)/firmware/sandbox/startup.s -o startup.o
	$(CCX) -c $(GIT_HOME)/firmware/sandbox/spi.c  -nostdlib -O2 -o spi.o
	$(LD) -T $(GIT_HOME)/firmware/sandbox/blink.ld spi.o -o spi.elf
	$(OBJCOPY) -O binary spi.elf spi.bin
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 spi.bin ram_bge.bin
	rm -f ram_image.v
	xxd -c 4 -p ram_bge.bin >> ram_image.v
	cp $(GIT_HOME)/verif/system/mem_Q128_bottom.vmf mem_Q128_bottom.vmf
	cp $(GIT_HOME)/verif/models/N25Q128A13E_VG12/sim/sfdp.vmf sfdp.vmf