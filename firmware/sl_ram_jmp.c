.global main
.org .+0x200
li s0, 0x2000
li s1, 0x18
lw s2, 0(s0)
sw s1, 0(s0)
lw s2, 0(s0)
j .+0x10000
nop

