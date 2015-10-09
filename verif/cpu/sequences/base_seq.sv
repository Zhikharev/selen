// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : base_seq.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_BASE_SEQ
`define INC_BASE_SEQ

class base_seq;

  function new ();
  endfunction 

  virtual task body();
  	$fatal("User must implement body method!")
  endtask 

endclass

`endif