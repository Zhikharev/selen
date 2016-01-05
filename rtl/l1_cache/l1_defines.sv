`define ASSERT_ONE_HOT(signal, en)\
	one_hot_``signal``_p:\
		assert property(@(posedge clk) en -> $onehot(signal) || signal == 0)\
		else $fatal("``signal`` onehot only expected!");

`define CORE_ADDR_WIDTH 32
`define CORE_COP_WIDTH  3