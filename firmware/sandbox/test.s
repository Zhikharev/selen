	.file	"blink.c"
	.text
	.align	2
	.globl	set_gpio
	.type	set_gpio, @function
set_gpio:
	add	a4,a0,36
.L2:
	add	a1,a1,1
	lbu	a5,-1(a1)
	add	a0,a0,1
	sb	a5,-1(a0)
	bne	a4,a0,.L2
	ret
	.size	set_gpio, .-set_gpio
	.align	2
	.globl	get_gpio
	.type	get_gpio, @function
get_gpio:
	add	a4,a1,36
.L6:
	add	a0,a0,1
	lbu	a5,-1(a0)
	add	a1,a1,1
	sb	a5,-1(a1)
	bne	a4,a1,.L6
	ret
	.size	get_gpio, .-get_gpio
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-48
	sw	zero,12(sp)
	sw	zero,16(sp)
	sw	zero,20(sp)
	sw	zero,24(sp)
	sw	zero,28(sp)
	sw	zero,32(sp)
	sw	zero,36(sp)
	sw	zero,40(sp)
	sw	zero,44(sp)
	add	a5,sp,12
	li	a4,8192
.L9:
	add	a5,a5,1
	lbu	a3,-1(a5)
	add	a4,a4,1
	sb	a3,-1(a4)
	add	a3,sp,48
	bne	a5,a3,.L9
	li	a2,8192
	add	a2,a2,36
.L15:
	li	a5,8192
	add	a4,sp,12
.L10:
	add	a5,a5,1
	lbu	a3,-1(a5)
	add	a4,a4,1
	sb	a3,-1(a4)
	bne	a5,a2,.L10
	lw	a5,12(sp)
	and	a5,a5,1
	beqz	a5,.L15
	li	a0,1
	add	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
