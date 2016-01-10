`define ASSERT_ONE_HOT(signal, en)\
	one_hot_``signal``_p:\
		assert property(@(posedge clk) en -> $onehot(signal) || signal == 0)\
		else $fatal("``signal`` onehot only expected!");

`define CORE_ADDR_WIDTH 	32
`define CORE_DATA_WIDTH     32
`define CORE_BE_WIDTH     	(`CORE_DATA_WIDTH / 8)
`define CORE_SIZE_WIDTH     2
`define CORE_COP_WIDTH 	 	3
`define CORE_TAG_WIDTH  	19
`define CORE_IDX_WIDTH  	8
`define CORE_OFFSET_WIDTH 	5

`define L1_LINE_SIZE 		256
`define L1_LD_MEM_WIDTH 	(`CORE_TAG_WIDTH + 1)
`define L1_WAY_NUM 			4


