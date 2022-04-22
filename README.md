# selen
SoC
Academic System on Chip based on RISC-V core, developed from scratch.
SoC contains:
- RISC-V in order, pipeline core
- L1 instruction and L1 data caches, 4-way associativitе write-through no-write-allocate
- Wishbone Interconnect
- SRAM, ROM wishbone controllers
- IO hub with SPI and GPIO

Target platfrom FPGA Spartan-6 (see main block diagram https://github.com/Zhikharev/selen/blob/master/doc/selen/selen-03.png).

Project includes SystemVerilog UVM 1.2 testbenchs for cache-controller and risc-v core. We introduce our custom, easy to use ISA simulator, which works good with SystemVerilig testbench. And the last, but not the least, you can find full system testbench and try to run different C/C++ programms. 

You can search for tag v1.0 and try the initial version of Selen project in your FPGA with booting programm from SPI flash memory.

<img src="http://www.xda-developers.com/wp-content/uploads/2016/01/riscv-blog-logo.png">
<img src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcR5ojY1hvgnKv5paAHNRG-_s-mZUgI-eqFm6e9j_gn8IIR2Ylms">


