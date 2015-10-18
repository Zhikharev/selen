
`include "testbench/wishborne_if.sv"
`include "testbench/rst_if.sv"

`include "base/cpu_base_component.sv"

`include "items/cpu_typedefs.sv"
`include "items/rv32_transaction.sv"
`include "sequences/base_seq.sv"

`include "drivers/cpu_wbi_driver.sv"
`include "drivers/cpu_wbd_driver.sv"

`include "monitors/cpu_wbi_monitor.sv"
`include "monitors/cpu_wbd_monitor.sv"

`include "agents/cpu_wbi_agent.sv"
`include "agents/cpu_wbd_agent.sv"

`include "environment/cpu_env.sv"

`include "sequences/cpu_draft_seq.sv"

`include "tests/base_test.sv"
`include "tests/draft_test.sv"
`include "tests/run_test.sv"

`include "testbench/cpu_assembled.sv"
`include "testbench/cpu_tb_top.sv"