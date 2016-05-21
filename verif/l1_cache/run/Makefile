BENCH_HOME := $(dir $(lastword $(MAKEFILE_LIST)))/..
TOP=l1_tb_top

include $(BENCH_HOME)/../../rtl/l1_cache/Makefrag
include $(BENCH_HOME)/../tools/Makefile.global

VLOG_OPTS = \
	+incdir+$(UVM_HOME)/src -timescale=1ns/1ps +define+USING_VCS  \
	-sverilog $(LINT) +nospecify +notimingchecks -l vlogan.log \
	$(RTL_SRC) $(VCS_RTL_INC) $(RTL_DEFINE) $(MODEL_SRC) $(TB_DEFINES)

include $(BENCH_HOME)/run/Makefrag

build: analyze elaborate

draft_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=draft_test $(RUN_OPTS) $(SIM_OPTS)

l1_rd_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=$@ $(RUN_OPTS) $(SIM_OPTS)

l1_rd_after_wr_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=$@ $(RUN_OPTS) $(SIM_OPTS)

l1_random_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=$@ $(RUN_OPTS) $(SIM_OPTS)

l1_lru_test:
	./simv +UVM_NO_RELNOTES +UVM_TESTNAME=$@ $(RUN_OPTS) $(SIM_OPTS)