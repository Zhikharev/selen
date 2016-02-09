# selen
SoC
Academic System on Chip based on RISC-V core, developed from scratch.
SoC contains:
- RISC-V in order, 5 stage pipeline core
- L1 instruction and L1 data caches, 4-way associativitе write-through no-write-allocate
- Wishbone Interconnect (AXI for private needs)
- SRAM, ROM wishbone controllers
- IO hub with SPI and GPIO

Target platfrom FPGA Spartan-6 (see main block diagram https://github.com/Zhikharev/selen/blob/master/doc/selen/selen.png).

We introduce assembler for RISC-V ISA, which supports our custom instructions. 
At last we designed simple ISA simulator to execute binary memory images.

<img src="https://blog.riscv.org/wp-content/uploads/2015/02/riscv-blog-logo.png">
<img src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcR5ojY1hvgnKv5paAHNRG-_s-mZUgI-eqFm6e9j_gn8IIR2Ylms">

For cooperation or any questions please contact gregory.zhiharev@gmail.com
