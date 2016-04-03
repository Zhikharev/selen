`ifndef UVM_INC
`define UVM_INC

`include "uvm_pkg.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;

// Common
`include "smart_report_server.sv"
`include "core/sl_core_inc.sv"
`include "wishbone/wb_inc.sv"
`include "rst_ifc/rst_ifc.inc.sv"

`include "uvm/scrb/sl_cache_typedefs.sv"

`include "uvm/cfg/l1_cfg.sv"

`include "uvm/scrb/sl_cache_line.sv"
`include "uvm/scrb/sl_mem.sv"
`include "uvm/scrb/sl_cache_mem.sv"
`include "uvm/scrb/sl_cache_scrb.sv"

`include "uvm/environment/l1_env.sv"

`include "uvm/sequences/draft_sequence.sv"
`include "uvm/sequences/wb_slave_response_sequence.sv"

`include "uvm/tests/l1_base_test.sv"

`endif