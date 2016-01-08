
`include "interface/wishbone_if.sv"
`include "interface/core_if.sv"
`include "interface/rst_if.sv"

`include "base/cpu_base_component.sv"

`include "items/cpu_typedefs.sv"
`include "items/rv32_transaction.sv"
`include "items/core_transaction.sv"

`include "sequences/base_seq.sv"

`include "drivers/cpu_corei_driver.sv"
`include "drivers/cpu_cored_driver.sv"

`include "monitors/cpu_corei_monitor.sv"
`include "monitors/cpu_cored_monitor.sv"

`include "agents/cpu_corei_agent.sv"
`include "agents/cpu_cored_agent.sv"

`include "environment/cpu_core_env.sv"

`include "sequences/cpu_draft_seq.sv"
`include "sequences/cpu_seq_lib.sv"

`include "tests/base_test.sv"
`include "tests/draft_test.sv"
`include "tests/test_lib.sv"
`include "tests/run_test.sv"

`include "testbench/core_assembled.sv"
`include "testbench/core_tb_top.sv"