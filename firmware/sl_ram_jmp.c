.global main
.org .+0x200
li s0, 0x2000
lw s1, 0(s0)
lw s1, 0(s0)
j .+0x10000
nop

