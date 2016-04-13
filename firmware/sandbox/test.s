	.file	"blink.c"
	.text
	.align	2
	.globl	wait
	.type	wait, @function
wait:
 #APP
# 57 "blink.c" 1
	rdcycle a2;
	rdcycleh a6;
# 0 "" 2
 #NO_APP
	or	a5,a0,a1
	beqz	a5,.L1
.L8:
 #APP
# 57 "blink.c" 1
	rdcycle a4;
	rdcycleh a5;
# 0 "" 2
 #NO_APP
	sub	a3,a4,a2
	sltu	a4,a4,a3
	sub	a5,a5,a6
	sub	a5,a5,a4
	bgtu	a1,a5,.L8
	bne	a1,a5,.L1
	bgtu	a0,a3,.L8
.L1:
	ret
	.size	wait, .-wait
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	add	s0,sp,48
	sw	zero,-20(s0)
	li	a5,1
	sw	a5,-24(s0)
	li	a5,8192
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	sw	zero,0(a5)
	lw	a5,-28(s0)
	sw	zero,4(a5)
	lw	a5,-28(s0)
	sw	zero,8(a5)
	lw	a5,-28(s0)
	sw	zero,12(a5)
	lw	a5,-28(s0)
	sw	zero,16(a5)
	lw	a5,-28(s0)
	sw	zero,20(a5)
	lw	a5,-28(s0)
	sw	zero,24(a5)
	lw	a5,-28(s0)
	sw	zero,28(a5)
	lw	a5,-28(s0)
	sw	zero,32(a5)
	lw	a5,-28(s0)
	lw	a4,8(a5)
	li	a3,1
	lw	a5,-20(s0)
	sll	a5,a3,a5
	not	a5,a5
	and	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,8(a5)
	lw	a5,-28(s0)
	lw	a5,24(a5)
	and	a4,a5,-2
	lw	a5,-28(s0)
	sw	a4,24(a5)
	lw	a5,-28(s0)
	lw	a4,12(a5)
	li	a3,1
	lw	a5,-20(s0)
	sll	a5,a3,a5
	not	a5,a5
	and	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,12(a5)
.L14:
	lw	a5,-28(s0)
	lw	a4,0(a5)
	lw	a5,-20(s0)
	srl	a5,a4,a5
	and	a5,a5,1
	bnez	a5,.L16
	j	.L14
.L16:
	nop
	lw	a5,-28(s0)
	lw	a4,8(a5)
	li	a3,1
	lw	a5,-24(s0)
	sll	a5,a3,a5
	or	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,8(a5)
	lw	a5,-28(s0)
	lw	a4,12(a5)
	li	a3,1
	lw	a5,-24(s0)
	sll	a5,a3,a5
	not	a5,a5
	and	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,12(a5)
	lw	a5,-28(s0)
	lw	a4,4(a5)
	li	a3,1
	lw	a5,-24(s0)
	sll	a5,a3,a5
	or	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,4(a5)
	li	a4,100
	li	a5,0
	sw	a4,-40(s0)
	sw	a5,-36(s0)
	lw	a0,-40(s0)
	lw	a1,-36(s0)
	call	wait
	lw	a5,-28(s0)
	lw	a4,4(a5)
	li	a3,1
	lw	a5,-24(s0)
	sll	a5,a3,a5
	not	a5,a5
	and	a4,a4,a5
	lw	a5,-28(s0)
	sw	a4,4(a5)
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	add	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
