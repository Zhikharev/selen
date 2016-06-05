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
	.type	spi_init, @function
spi_init:
	li	a3,8192	# tmp79,
	sw	zero,32(a3)	#, MEM[(volatile struct SPI *)8192B].CTRL
.L2:
	lw	a5,32(a3)	# D.1525, MEM[(volatile struct SPI *)8192B].CTRL
	li	a4,8192	# tmp80,
	and	a5,a5,1	# D.1525, D.1525,
	bnez	a5,.L2	#, D.1525,
	li	a5,1	# tmp83,
	sw	a5,36(a4)	# tmp83, MEM[(volatile struct SPI *)8192B].DIVIDER
	lw	a5,36(a4)	# D.1525, MEM[(volatile struct SPI *)8192B].DIVIDER
	mv	a0,a4	#, tmp80
	and	a5,a5,-64	# D.1525, D.1525,
	or	a5,a5,32	# D.1526, D.1525,
	sw	a5,32(a4)	# D.1526, MEM[(volatile struct SPI *)8192B].CTRL
	ret
	.size	spi_init, .-spi_init
	.align	2
	.globl	spi_transaction
	.type	spi_transaction, @function
spi_transaction:
	lw	a5,40(a0)	# D.1529, spi_2(D)->SS
	or	a5,a5,1	# D.1529, D.1529,
	sw	a5,40(a0)	# D.1529, spi_2(D)->SS
	lw	a5,32(a0)	# D.1529, spi_2(D)->CTRL
	or	a5,a5,1	# D.1529, D.1529,
	sw	a5,32(a0)	# D.1529, spi_2(D)->CTRL
.L6:
	lw	a5,32(a0)	# D.1529, spi_2(D)->CTRL
	and	a5,a5,1	# D.1529, D.1529,
	bnez	a5,.L6	#, D.1529,
	lw	a5,40(a0)	# D.1529, spi_2(D)->SS
	and	a5,a5,-2	# D.1529, D.1529,
	sw	a5,40(a0)	# D.1529, spi_2(D)->SS
	ret
	.size	spi_transaction, .-spi_transaction
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-16	#,,
	sw	ra,12(sp)	#,
	sw	s0,8(sp)	#,
	call	spi_init	#
	li	a5,-559038464	# tmp76,
	add	a5,a5,-337	# tmp75, tmp76,
	sw	a5,16(a0)	# tmp75, spi_3->T
	mv	s0,a0	# spi,
	call	spi_transaction	#
	lw	ra,12(sp)	#,
	lw	a5,0(s0)	# received, spi_3->R
	li	a0,1	#,
	lw	s0,8(sp)	#,
	add	sp,sp,16	#,,
	jr	ra	#
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"