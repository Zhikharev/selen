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
	.type	wait, @function
wait:
 #APP
# 43 "blink.c" 1
	rdcycle a2;	# low
	rdcycleh a6;	# high
# 0 "" 2
 #NO_APP
	or	a5,a0,a1	# ticks_to_wait, ticks_to_wait, ticks_to_wait
	beqz	a5,.L1	#, ticks_to_wait,
.L8:
 #APP
# 43 "blink.c" 1
	rdcycle a4;	# low
	rdcycleh a5;	# high
# 0 "" 2
 #NO_APP
	sub	a3,a4,a2	# ticks_elapsed, low, low
	sltu	a4,a4,a3	# tmp100, low, ticks_elapsed
	sub	a5,a5,a6	# ticks_elapsed, high, high
	sub	a5,a5,a4	# tmp101, ticks_elapsed, tmp100
	bgtu	a1,a5,.L8	#, ticks_to_wait, tmp101,
	bne	a1,a5,.L1	#, ticks_to_wait, tmp101,
	bgtu	a0,a3,.L8	#, ticks_to_wait, ticks_elapsed,
.L1:
	ret
	.size	wait, .-wait
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-48	#,,
	sw	ra,44(sp)	#,
	sw	s0,40(sp)	#,
	add	s0,sp,48	#,,
	sw	zero,-20(s0)	#, input_pin
	li	a5,1	# tmp99,
	sw	a5,-24(s0)	# tmp99, output_pin
	li	a5,8192	# tmp100,
	sw	a5,-28(s0)	# tmp100, gpio
	lw	a5,-28(s0)	# tmp101, gpio
	sw	zero,0(a5)	#, gpio_3->in
	lw	a5,-28(s0)	# tmp102, gpio
	sw	zero,4(a5)	#, gpio_3->out
	lw	a5,-28(s0)	# tmp103, gpio
	sw	zero,8(a5)	#, gpio_3->oe
	lw	a5,-28(s0)	# tmp104, gpio
	sw	zero,12(a5)	#, gpio_3->inte
	lw	a5,-28(s0)	# tmp105, gpio
	sw	zero,16(a5)	#, gpio_3->ptrig
	lw	a5,-28(s0)	# tmp106, gpio
	sw	zero,20(a5)	#, gpio_3->aux
	lw	a5,-28(s0)	# tmp107, gpio
	sw	zero,24(a5)	#, gpio_3->ctrl
	lw	a5,-28(s0)	# tmp108, gpio
	sw	zero,28(a5)	#, gpio_3->eclk
	lw	a5,-28(s0)	# tmp109, gpio
	sw	zero,32(a5)	#, gpio_3->nec
	lw	a5,-28(s0)	# tmp110, gpio
	lw	a4,8(a5)	# D.1537, gpio_3->oe
	li	a3,1	# tmp111,
	lw	a5,-20(s0)	# tmp112, input_pin
	sll	a5,a3,a5	# D.1537, tmp111, tmp112
	not	a5,a5	# D.1537, D.1537
	and	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp113, gpio
	sw	a4,8(a5)	# D.1537, gpio_3->oe
	lw	a5,-28(s0)	# tmp114, gpio
	lw	a5,24(a5)	# D.1537, gpio_3->ctrl
	and	a4,a5,-2	# D.1537, D.1537,
	lw	a5,-28(s0)	# tmp115, gpio
	sw	a4,24(a5)	# D.1537, gpio_3->ctrl
	lw	a5,-28(s0)	# tmp116, gpio
	lw	a4,12(a5)	# D.1537, gpio_3->inte
	li	a3,1	# tmp117,
	lw	a5,-20(s0)	# tmp118, input_pin
	sll	a5,a3,a5	# D.1537, tmp117, tmp118
	not	a5,a5	# D.1537, D.1537
	and	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp119, gpio
	sw	a4,12(a5)	# D.1537, gpio_3->inte
.L14:
	lw	a5,-28(s0)	# tmp120, gpio
	lw	a4,0(a5)	# D.1537, gpio_3->in
	li	a3,1	# tmp121,
	lw	a5,-20(s0)	# tmp122, input_pin
	sll	a5,a3,a5	# D.1537, tmp121, tmp122
	and	a5,a4,a5	# D.1537, D.1537, D.1537
	bnez	a5,.L16	#, D.1537,
	j	.L14	#
.L16:
	nop
	lw	a5,-28(s0)	# tmp123, gpio
	lw	a4,8(a5)	# D.1537, gpio_3->oe
	li	a3,1	# tmp124,
	lw	a5,-24(s0)	# tmp125, output_pin
	sll	a5,a3,a5	# D.1537, tmp124, tmp125
	or	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp126, gpio
	sw	a4,8(a5)	# D.1537, gpio_3->oe
	lw	a5,-28(s0)	# tmp127, gpio
	lw	a4,12(a5)	# D.1537, gpio_3->inte
	li	a3,1	# tmp128,
	lw	a5,-24(s0)	# tmp129, output_pin
	sll	a5,a3,a5	# D.1537, tmp128, tmp129
	not	a5,a5	# D.1537, D.1537
	and	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp130, gpio
	sw	a4,12(a5)	# D.1537, gpio_3->inte
	lw	a5,-28(s0)	# tmp131, gpio
	lw	a4,4(a5)	# D.1537, gpio_3->out
	li	a3,1	# tmp132,
	lw	a5,-24(s0)	# tmp133, output_pin
	sll	a5,a3,a5	# D.1537, tmp132, tmp133
	or	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp134, gpio
	sw	a4,4(a5)	# D.1537, gpio_3->out
	li	a4,100	# tmp135,
	li	a5,0	#,
	sw	a4,-40(s0)	# tmp135, ticks_to_wait
	sw	a5,-36(s0)	#, ticks_to_wait
	lw	a0,-40(s0)	#, ticks_to_wait
	lw	a1,-36(s0)	#, ticks_to_wait
	call	wait	#
	lw	a5,-28(s0)	# tmp136, gpio
	lw	a4,4(a5)	# D.1537, gpio_3->out
	li	a3,1	# tmp137,
	lw	a5,-24(s0)	# tmp138, output_pin
	sll	a5,a3,a5	# D.1537, tmp137, tmp138
	not	a5,a5	# D.1537, D.1537
	and	a4,a4,a5	# D.1537, D.1537, D.1537
	lw	a5,-28(s0)	# tmp139, gpio
	sw	a4,4(a5)	# D.1537, gpio_3->out
	nop
	lw	ra,44(sp)	#,
	lw	s0,40(sp)	#,
	add	sp,sp,48	#,,
	jr	ra	#
	.size	main, .-main
	.ident	"GCC: (GNU) 5.3.0"
