// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_draft_seq.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_DRAFT_SEQ
`define INC_CPU_DRAFT_SEQ

class cpu_draft_seq extends base_seq;

  function new ();
  	super.new();
  endfunction 

  task body();
    $display("[%0t][SEQ] Start of 'cpu_draft_seq'", $time);
    repeat(10) begin
    	req = new();
    	assert(req.randomize() with {req.opcode inside {ADD, SLT, SLTU, AND, OR, XOR, SLL, SRL};})
    	else $fatal("Randomization failed!");
    	req_q.push_back(req);
   	end
    $display ("[%0t][SEQ] End of 'cpu_draft_seq'", $time);  
  endtask 

endclass

`endif