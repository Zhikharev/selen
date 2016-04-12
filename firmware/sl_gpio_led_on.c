.global main
.org .+0x200

# Load gpio base addr
li s0, 0x2000

# Set output en led0
li s1, 0x1
sw s1, 8(s0)

# Drive 1 on led0
sw s1, 4(s0)

# Check led0, must be 0x1
# if right tri-state pin connection
lw s2, 0(s0)

# jump to ram
li s0, 0x100000
jr s0
