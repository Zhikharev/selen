SystemVerilog UVM-1.2 Testbench with C++ RISCV ISA model.

1. [Quickstart](#quickstart)

# <a name="quickstart"></a>Quickstart

	export GIT_HOME=<path to git repository> 
	export UVM_HOME=<path to uvm-1.2 folder>
	make -f $GIT_HOME/verif/core/run/Makefile build draft_test SIM_OPTS="+num_pkts=10"

You need VSC to use this example. For GUI usage add -gui to SIM_OPTS

