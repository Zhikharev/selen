// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_seq_lib.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_SEQ_LIB
`define INC_CPU_SEQ_LIB

class cpu_direct_seq extends base_seq;

  function new ();
    super.new();
  endfunction 

  function create_req_with_opcode(opcode_type cop);
    req = new();
    assert(req.randomize())
    else $fatal("Randomization failed!");
    req.opcode = cop;
    req_q.push_back(req);
  endfunction

  task body();
    $display("[%0t][SEQ] Start of 'cpu_direct_seq'", $time);
    create_req_with_opcode(ADD);
    create_req_with_opcode(SLT);
    $display ("[%0t][SEQ] End of 'cpu_draft_seq'", $time);  
  endtask 

endclass

class cpu_load_seq extends base_seq;

  function new ();
    super.new();
  endfunction 

  task body();
    $display("[%0t][SEQ] Start of 'cpu_load_seq'", $time);
    repeat(10) begin
      req = new();
      assert(req.randomize() with {
        req.opcode == LW;
        req.rd inside {[1:25]};
      })
      else $fatal("Randomization failed!");
      req_q.push_back(req);
    end
    $display ("[%0t][SEQ] End of 'cpu_load_seq'", $time);  
  endtask 

endclass

`endif