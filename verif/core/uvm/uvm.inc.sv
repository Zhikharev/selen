`ifndef UVM_INC
`define UVM_INC

`include "uvm_pkg.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;

// Common
`include "smart_report_server.sv"
`include "core/sl_core_inc.sv"

`include "uvm/items/rv32_typedefs.sv"
`include "uvm/items/rv32_transaction.sv"
`include "uvm/sequencer/sl_rv32_layer_sequencer.sv"
`include "uvm/env/sl_core_env.sv"
`include "uvm/sequences/sl_rv32_core_translate_seq.sv"
`include "uvm/sequences/sl_draft_seq_lib.sv"
`include "uvm/test/sl_core_base_test.sv"

`endif