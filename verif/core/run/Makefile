BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))/..
TOP=core_tb_top
CPU=SELEN

ifeq ($(CPU), SELEN)
	include $(BENCH_HOME)/../../rtl/core/Makefrag
else
	include $(BENCH_HOME)/../../rtl/vscale/Makefrag
endif

include $(BENCH_HOME)/../tools/Makefile.global
include $(BENCH_HOME)/run/Makefrag

build: analyze elaborate

draft_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=draft_test $(RUN_OPTS) $(SIM_OPTS)

core_run_opcodes_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=core_run_opcodes_test $(RUN_OPTS) $(SIM_OPTS)

