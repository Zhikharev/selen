// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : test_lib.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_TEST_LIB
`define INC_TEST_LIB

class direct_test extends base_test; 

  cpu_load_seq   load_seq;
  cpu_direct_seq direct_seq;

  `test_utils(`if_type)

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    load_seq = new();
    env.seq_q.push_back(load_seq);
    direct_seq = new();
    env.seq_q.push_back(direct_seq);
    env.build_phase();
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
  endfunction

endclass

class certain_inst extends base_test;

	cpu_test_seq   load_seq;
  cpu_direct_seq direct_seq;

  `test_utils(`if_type)

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    load_seq = new();
    env.seq_q.push_back(load_seq);
    direct_seq = new();
    env.seq_q.push_back(direct_seq);
    env.build_phase();
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
	endfunction
  
endclass

class ADDI_inst extends base_test;

	cpu_ADDI_seq   load_seq;
  cpu_direct_seq direct_seq;

  `test_utils(`if_type)

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    load_seq = new();
    env.seq_q.push_back(load_seq);
    direct_seq = new();
    env.seq_q.push_back(direct_seq);
    env.build_phase();
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
  endfunction
  
endclass

class bp_inst extends base_test;

	cpu_ADDI_seq   load_seq;
  cpu_bp_seq direct_seq;

  `test_utils(`if_type)

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    load_seq = new();
    env.seq_q.push_back(load_seq);
    direct_seq = new();
    env.seq_q.push_back(direct_seq);
    env.build_phase();
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
  endfunction
  
endclass

`endif
