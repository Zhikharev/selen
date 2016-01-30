`ifndef UVM_INC
`define UVM_INC

`include "uvm_pkg.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;

`include "uvm/items/rv32_typedefs.sv"
`include "uvm/items/rv32_transaction.sv"
`include "uvm/drivers/sl_core_i_drv.sv"
`include "uvm/agents/sl_core_i_agent.sv"
`include "uvm/env/sl_core_env.sv"
`include "uvm/sequences/sl_draft_seq_lib.sv"
`include "uvm/test/sl_core_base_test.sv"

`endif