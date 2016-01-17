	.file	"test.cpp"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	add	sp,sp,-32
	.cfi_def_cfa_offset 32
	sd	s0,24(sp)
	.cfi_offset 8, -8
	add	s0,sp,32
	.cfi_def_cfa 8, 0
	li	a5,1
	sw	a5,-24(s0)
	li	a5,3
	sw	a5,-28(s0)
	sw	zero,-20(s0)
.L3:
	lw	a4,-20(s0)
	li	a5,3
	bgt	a4,a5,.L2
	lw	a5,-28(s0)
	addw	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	addw	a5,a5,1
	sw	a5,-20(s0)
	j	.L3
.L2:
	lw	a5,-24(s0)
	mv	a0,a5
	ld	s0,24(sp)
	add	sp,sp,32
	jr	ra
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
