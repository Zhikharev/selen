	.file	"blink.c"
# GNU C11 (GCC) version 5.3.0 (riscv64-unknown-elf)
#	compiled by GNU C version 5.2.0, GMP version 5.1.3, MPFR version 3.1.3, MPC version 1.0.1
# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  -imultilib 32 blink.c -m32 -auxbase-strip test.s -O2
# -Wall -fomit-frame-pointer -fverbose-asm
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
	.type	wait.constprop.0, @function
wait.constprop.0:
 #APP
# 43 "blink.c" 1
	rdcycle a2;	# low
	rdcycleh a1;	# high
# 0 "" 2
 #NO_APP
	li	a0,99	# tmp119,
.L2:
 #APP
# 43 "blink.c" 1
	rdcycle a5;	# low
	rdcycleh a4;	# high
# 0 "" 2
 #NO_APP
	sub	a3,a5,a2	# ticks_elapsed, low, low
	sltu	a5,a5,a3	# tmp98, low, ticks_elapsed
	sub	a4,a4,a1	# ticks_elapsed, high, high
	bne	a4,a5,.L1	#, ticks_elapsed, tmp98,
	bleu	a3,a0,.L2	#, ticks_elapsed, tmp119,
.L1:
	ret
	.size	wait.constprop.0, .-wait.constprop.0
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-16	#,,
	li	a5,8192	# tmp88,
	sw	ra,12(sp)	#,
	sw	s0,8(sp)	#,
	sw	zero,0(a5)	#, MEM[(volatile struct GPIO *)8192B].in
	sw	zero,4(a5)	#, MEM[(volatile struct GPIO *)8192B].out
	sw	zero,8(a5)	#, MEM[(volatile struct GPIO *)8192B].oe
	sw	zero,12(a5)	#, MEM[(volatile struct GPIO *)8192B].inte
	sw	zero,16(a5)	#, MEM[(volatile struct GPIO *)8192B].ptrig
	sw	zero,20(a5)	#, MEM[(volatile struct GPIO *)8192B].aux
	sw	zero,24(a5)	#, MEM[(volatile struct GPIO *)8192B].ctrl
	sw	zero,28(a5)	#, MEM[(volatile struct GPIO *)8192B].eclk
	sw	zero,32(a5)	#, MEM[(volatile struct GPIO *)8192B].nec
	lw	a4,8(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].oe
	and	a4,a4,-2	# D.1538, D.1538,
	sw	a4,8(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].oe
	lw	a4,24(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].ctrl
	and	a4,a4,-2	# D.1538, D.1538,
	sw	a4,24(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].ctrl
	lw	a4,12(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].inte
	and	a4,a4,-2	# D.1538, D.1538,
	sw	a4,12(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].inte
.L6:
	lw	a4,0(a5)	# D.1538, MEM[(volatile struct GPIO *)8192B].in
	li	s0,8192	# tmp103,
	and	a4,a4,1	# D.1538, D.1538,
	beqz	a4,.L6	#, D.1538,
	lw	a5,8(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].oe
	or	a5,a5,2	# D.1538, D.1538,
	sw	a5,8(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].oe
	lw	a5,12(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].inte
	and	a5,a5,-3	# D.1538, D.1538,
	sw	a5,12(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].inte
	lw	a5,4(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].out
	or	a5,a5,2	# D.1538, D.1538,
	sw	a5,4(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].out
	call	wait.constprop.0	#
	lw	a5,4(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].out
	lw	ra,12(sp)	#,
	and	a5,a5,-3	# D.1538, D.1538,
	sw	a5,4(s0)	# D.1538, MEM[(volatile struct GPIO *)8192B].out
	lw	s0,8(sp)	#,
	add	sp,sp,16	#,,
	jr	ra	#
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
