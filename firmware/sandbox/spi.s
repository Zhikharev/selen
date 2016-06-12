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
	lw	a5,24(a0)	# D.1573, spi_3(D)->SS
	or	a5,a5,1	# D.1573, D.1573,
	sw	a5,24(a0)	# D.1573, spi_3(D)->SS
	lw	a5,16(a0)	# D.1573, spi_3(D)->CTRL
	or	a5,a5,256	# D.1573, D.1573,
	sw	a5,16(a0)	# D.1573, spi_3(D)->CTRL
	j	.L6	#
.L8:
	lw	a5,24(a0)	# D.1573, spi_3(D)->SS
	and	a5,a5,-2	# D.1573, D.1573,
	sw	a5,24(a0)	# D.1573, spi_3(D)->SS
.L6:
	lw	a5,16(a0)	# D.1573,
	and	a5,a5,256	# D.1573, D.1573,
	bnez	a5,.L8	#, D.1573,
	ret
	.size	spi_transaction, .-spi_transaction
	.align	2
	.globl	load_from_flash
	.type	load_from_flash, @function
load_from_flash:
	li	a4,4096	# tmp104,
	sw	zero,16(a4)	#, MEM[(volatile struct SPI *)4096B].CTRL
.L10:
	lw	a5,16(a4)	# D.1589, MEM[(volatile struct SPI *)4096B].CTRL
	li	a3,4096	# tmp105,
	and	a5,a5,256	# D.1589, D.1589,
	bnez	a5,.L10	#, D.1589,
	li	a5,4	# tmp108,
	sw	a5,20(a3)	# tmp108, MEM[(volatile struct SPI *)4096B].DIVIDER
	lw	a5,16(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].CTRL
	li	t3,16777216	# tmp133,
	li	t1,0	# received,
	and	a5,a5,-128	# D.1590, D.1589,
	sw	a5,16(a3)	# D.1590, MEM[(volatile struct SPI *)4096B].CTRL
	add	t3,t3,-1	# tmp134, tmp133,
	li	t4,50331648	# tmp135,
	beqz	a2,.L9	#, size,
.L19:
	add	a5,a1,t1	# D.1589, start_address, received
	and	a5,a5,t3	# address, D.1589, tmp134
	or	a5,a5,t4	# D.1589, address, tmp135
	sw	a5,12(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].DATA
	lw	a5,24(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].SS
	or	a5,a5,1	# D.1589, D.1589,
	sw	a5,24(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].SS
	lw	a5,16(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].CTRL
	or	a5,a5,256	# D.1589, D.1589,
	sw	a5,16(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].CTRL
	j	.L26	#
.L27:
	lw	a5,24(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].SS
	and	a5,a5,-2	# D.1589, D.1589,
	sw	a5,24(a3)	# D.1589, MEM[(volatile struct SPI *)4096B].SS
.L26:
	lw	a5,16(a3)	# D.1589,
	and	a5,a5,256	# D.1589, D.1589,
	bnez	a5,.L27	#, D.1589,
	li	a5,4096	# ivtmp.18,
	add	a6,a0,t1	# ivtmp.19, destination, received
	add	a7,a5,12	# D.1594, ivtmp.18,
.L14:
	lbu	a4,0(a5)	#, *_24
	add	a6,a6,1	# ivtmp.19, ivtmp.19,
	add	a5,a5,1	# ivtmp.18, ivtmp.18,
	and	a4,a4,0xff	# D.1592, *_24
	sb	a4,-1(a6)	# D.1592, *_23
	bne	a5,a7,.L14	#, ivtmp.18, D.1594,
	add	t1,t1,12	# received, received,
	bgtu	a2,t1,.L19	#, size, received,
	ret
.L9:
	ret
	.size	load_from_flash, .-load_from_flash
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-16	#,,
	sw	s0,8(sp)	#,
	li	s0,16777216	# tmp74,
	add	s0,s0,-1	# tmp73, tmp74,
	li	a2,1024	#,
	li	a1,4	#,
	mv	a0,s0	#, tmp73
	sw	ra,12(sp)	#,
	call	load_from_flash	#
 #APP
# 154 "spi.c" 1
	jalr x0, s0	# tmp73
nop
nop
nop

# 0 "" 2
 #NO_APP
	lw	ra,12(sp)	#,
	li	a0,1	#,
	lw	s0,8(sp)	#,
	add	sp,sp,16	#,,
	jr	ra	#
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
