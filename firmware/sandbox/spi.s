	.file	"spi.c"
# GNU C11 (GCC) version 5.3.0 (riscv64-unknown-elf)
#	compiled by GNU C version 5.2.0, GMP version 5.1.3, MPFR version 3.1.3, MPC version 1.0.1
# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  -imultilib 32 spi.c -m32 -auxbase-strip spi.s -O2 -Wall
# -fomit-frame-pointer -fverbose-asm
# options enabled:  -faggressive-loop-optimizations -falign-functions
# -falign-jumps -falign-labels -falign-loops -fauto-inc-dec
# -fbranch-count-reg -fcaller-saves -fchkp-check-incomplete-type
# -fchkp-check-read -fchkp-check-write -fchkp-instrument-calls
# -fchkp-narrow-bounds -fchkp-optimize -fchkp-store-bounds
# -fchkp-use-static-bounds -fchkp-use-static-const-bounds
# -fchkp-use-wrappers -fcombine-stack-adjustments -fcommon -fcompare-elim
# -fcprop-registers -fcrossjumping -fcse-follow-jumps -fdefer-pop
# -fdelete-null-pointer-checks -fdevirtualize -fdevirtualize-speculatively
# -fdwarf2-cfi-asm -fearly-inlining -feliminate-unused-debug-types
# -fexpensive-optimizations -fforward-propagate -ffunction-cse -fgcse
# -fgcse-lm -fgnu-runtime -fgnu-unique -fguess-branch-probability
# -fhoist-adjacent-loads -fident -fif-conversion -fif-conversion2
# -findirect-inlining -finline -finline-atomics
# -finline-functions-called-once -finline-small-functions -fipa-cp
# -fipa-cp-alignment -fipa-icf -fipa-icf-functions -fipa-icf-variables
# -fipa-profile -fipa-pure-const -fipa-ra -fipa-reference -fipa-sra
# -fira-hoist-pressure -fira-share-save-slots -fira-share-spill-slots
# -fisolate-erroneous-paths-dereference -fivopts -fkeep-static-consts
# -fleading-underscore -flifetime-dse -flra-remat -flto-odr-type-merging
# -fmath-errno -fmerge-constants -fmerge-debug-strings
# -fmove-loop-invariants -fomit-frame-pointer -foptimize-sibling-calls
# -foptimize-strlen -fpartial-inlining -fpeephole -fpeephole2
# -fprefetch-loop-arrays -freg-struct-return -freorder-blocks
# -freorder-functions -frerun-cse-after-loop
# -fsched-critical-path-heuristic -fsched-dep-count-heuristic
# -fsched-group-heuristic -fsched-interblock -fsched-last-insn-heuristic
# -fsched-rank-heuristic -fsched-spec -fsched-spec-insn-heuristic
# -fsched-stalled-insns-dep -fschedule-fusion -fschedule-insns
# -fschedule-insns2 -fsection-anchors -fsemantic-interposition
# -fshow-column -fshrink-wrap -fsigned-zeros -fsplit-ivs-in-unroller
# -fsplit-wide-types -fssa-phiopt -fstdarg-opt -fstrict-aliasing
# -fstrict-overflow -fstrict-volatile-bitfields -fsync-libcalls
# -fthread-jumps -ftoplevel-reorder -ftrapping-math -ftree-bit-ccp
# -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-coalesce-vars
# -ftree-copy-prop -ftree-copyrename -ftree-dce -ftree-dominator-opts
# -ftree-dse -ftree-forwprop -ftree-fre -ftree-loop-if-convert
# -ftree-loop-im -ftree-loop-ivcanon -ftree-loop-optimize
# -ftree-parallelize-loops= -ftree-phiprop -ftree-pre -ftree-pta
# -ftree-reassoc -ftree-scev-cprop -ftree-sink -ftree-slsr -ftree-sra
# -ftree-switch-conversion -ftree-tail-merge -ftree-ter -ftree-vrp
# -funit-at-a-time -fverbose-asm -fzero-initialized-in-bss -matomic -mfdiv
# -mhard-float -mmuldiv -mplt

	.text
	.align	2
	.globl	spi_transaction
	.type	spi_transaction, @function
spi_transaction:
	lw	a5,24(a0)	# D.1580, spi_3(D)->SS
	or	a5,a5,1	# D.1580, D.1580,
	sw	a5,24(a0)	# D.1580, spi_3(D)->SS
	lw	a5,16(a0)	# D.1580, spi_3(D)->CTRL
	or	a5,a5,256	# D.1580, D.1580,
	sw	a5,16(a0)	# D.1580, spi_3(D)->CTRL
	j	.L6	#
.L8:
	lw	a5,24(a0)	# D.1580, spi_3(D)->SS
	and	a5,a5,-2	# D.1580, D.1580,
	sw	a5,24(a0)	# D.1580, spi_3(D)->SS
.L6:
	lw	a5,16(a0)	# D.1580,
	and	a5,a5,256	# D.1580, D.1580,
	bnez	a5,.L8	#, D.1580,
	ret
	.size	spi_transaction, .-spi_transaction
	.align	2
	.globl	spi_read
	.type	spi_read, @function
spi_read:
	lw	a4,16(a0)	# D.1583, spi_5(D)->CTRL
	lw	a3,16(a0)	# D.1583, spi_5(D)->CTRL
	li	a5,16777216	# tmp94,
	add	a5,a5,-1	# tmp93, tmp94,
	sll	a2,a3,20	# tmp106, D.1583,
	and	a1,a1,a5	# address, address, tmp93
	li	a5,0	# index,
	bltz	a2,.L10	#, tmp106,
	and	a5,a4,63	# D.1584, D.1583,
	li	a3,32	# tmp98,
	bgtu	a5,a3,.L22	#, D.1584, tmp98,
.L11:
 #APP
# 93 "spi.h" 1
	j _exit

# 0 "" 2
 #NO_APP
.L12:
	srl	a5,a5,5	# D.1583, D.1584,
	add	a5,a5,-1	# index, D.1583,
.L10:
	sll	a5,a5,2	# tmp102, index,
	li	a4,50331648	# tmp101,
	add	a5,a0,a5	# tmp103, spi, tmp102
	or	a1,a1,a4	# D.1583, address, tmp101
	sw	a1,0(a5)	# D.1583, spi_5(D)->DATA
	lw	a5,24(a0)	# D.1583, spi_5(D)->SS
	or	a5,a5,1	# D.1583, D.1583,
	sw	a5,24(a0)	# D.1583, spi_5(D)->SS
	lw	a5,16(a0)	# D.1583, spi_5(D)->CTRL
	or	a5,a5,256	# D.1583, D.1583,
	sw	a5,16(a0)	# D.1583, spi_5(D)->CTRL
	j	.L21	#
.L23:
	lw	a5,24(a0)	# D.1583, spi_5(D)->SS
	and	a5,a5,-2	# D.1583, D.1583,
	sw	a5,24(a0)	# D.1583, spi_5(D)->SS
.L21:
	lw	a5,16(a0)	# D.1583,
	and	a5,a5,256	# D.1583, D.1583,
	bnez	a5,.L23	#, D.1583,
	ret
.L22:
	and	a4,a4,31	# D.1583, D.1583,
	beqz	a4,.L12	#, D.1583,
	j	.L11	#
	.size	spi_read, .-spi_read
	.align	2
	.globl	flash_read_word
	.type	flash_read_word, @function
flash_read_word:
	add	sp,sp,-16	#,,
	sw	ra,12(sp)	#,
	sw	s0,8(sp)	#,
	li	a4,4096	# tmp83,
	mv	a1,a0	# address, address
	sw	zero,16(a4)	#, MEM[(volatile struct SPI *)4096B].CTRL
.L25:
	lw	a5,16(a4)	# D.1587, MEM[(volatile struct SPI *)4096B].CTRL
	li	s0,4096	# tmp84,
	and	a5,a5,256	# D.1587, D.1587,
	bnez	a5,.L25	#, D.1587,
	li	a5,4	# tmp87,
	sw	a5,20(s0)	# tmp87, MEM[(volatile struct SPI *)4096B].DIVIDER
	lw	a5,16(s0)	# D.1587, MEM[(volatile struct SPI *)4096B].CTRL
	add	a4,s0,-2048	# tmp93, tmp84,
	mv	a0,s0	#, tmp84
	and	a5,a5,-128	# D.1587, D.1587,
	or	a5,a5,32	# D.1588, D.1587,
	sw	a5,16(s0)	# D.1588, MEM[(volatile struct SPI *)4096B].CTRL
	lw	a5,16(s0)	# D.1587, MEM[(volatile struct SPI *)4096B].CTRL
	or	a5,a5,a4	# D.1587, D.1587, tmp93
	sw	a5,16(s0)	# D.1587, MEM[(volatile struct SPI *)4096B].CTRL
	call	spi_read	#
	lw	ra,12(sp)	#,
	lw	a0,0(s0)	# D.1588, MEM[(volatile struct SPI *)4096B].DATA
	lw	s0,8(sp)	#,
	add	sp,sp,16	#,,
	jr	ra	#
	.size	flash_read_word, .-flash_read_word
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-32	#,,
	li	a0,0	#,
	sw	s0,24(sp)	#,
	sw	s2,16(sp)	#,
	sw	s3,12(sp)	#,
	sw	ra,28(sp)	#,
	sw	s1,20(sp)	#,
	call	flash_read_word	#
	mv	s3,a0	# size,
	li	s0,0	# received,
	li	s2,1048576	# tmp80,
.L29:
	add	s1,s0,s2	# D.1605, received, tmp80
	bgeu	s0,s3,.L32	#, received, size,
	add	s0,s0,4	# received, received,
	mv	a0,s0	#, received
	call	flash_read_word	#
	sw	a0,0(s1)	# D.1603, *_14
	j	.L29	#
.L32:
 #APP
# 30 "utils.h" 1
	jalr x0, s1	# D.1605
nop
nop
nop

# 0 "" 2
 #NO_APP
	lw	ra,28(sp)	#,
	li	a0,1	#,
	lw	s0,24(sp)	#,
	lw	s1,20(sp)	#,
	lw	s2,16(sp)	#,
	lw	s3,12(sp)	#,
	add	sp,sp,32	#,,
	jr	ra	#
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
