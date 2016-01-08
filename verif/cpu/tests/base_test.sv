// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : base_test.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_BASE_TEST
`define INC_BASE_TEST

class base_test extends cpu_base_component #(virtual core_if); 

  `env_inst(`if_type)
  `test_utils(`if_type)

  function void build_phase();
    $display("[%0t][TEST][BUILD] Phase started", $time);
    $display ("[%0t][TEST][BUILD] Phase ended", $time);   
  endfunction

  virtual task run_phase();
    $display("[%0t][BASE TEST][RUN] Phase started", $time);
    env.run_phase();
    $display ("[%0t][BASE TEST][RUN] Phase ended", $time);  
  endtask

  function void report_phase();
    $display("[%0t][REPORT] Phase started", $time);
    $display ("[%0t][REPORT] Phase ended", $time);   
  endfunction

endclass

`endif