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
    $display ("[%0t][SEQ] End of 'cpu_draft_seq'", $time);  
  endtask 

endclass

`endif