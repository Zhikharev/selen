// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : rv32_transaction.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_RV32_TRANSACTION
`define INC_RV32_TRANSACTION

class rv32_transaction; 

  rand rv32_opcode opcode;

  function new ();
  endfunction 

  function string sprint();
  	string str;
  	
  	// TODO

  	return(str);
  endfunction

  function void decode(bit [31:0] data);

  	// TODO

  endfunction

  function bit [31:0] encode();
  	bit [31:0] instr;

  	// TODO

  	return(instr);
  endfunction

endclass

`endif