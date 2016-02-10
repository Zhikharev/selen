BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
TOP=selen_tb_top

include $(BENCH_HOME)/../../rtl/top/Makefrag
include $(BENCH_HOME)/../tools/Makefile.global
#include $(BENCH_HOME)/run/Makefrag

build: analyze elaborate

draft_test:
	./simv +UVM_NO_RELNOTES -l test.log +UVM_TESTNAME=draft_test $(RUN_OPTS) $(SIM_OPTS)

