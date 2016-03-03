BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
TOP=selen_tb_top

include $(BENCH_HOME)/../../rtl/top/Makefrag
include $(BENCH_HOME)/../tools/Makefile.global
include $(BENCH_HOME)/Makefrag

build: analyze elaborate

sim:
	./simv -l test.log $(RUN_OPTS) $(SIM_OPTS)

