// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : core_transaction.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CORE_TRANSACTION
`define INC_CORE_TRANSACTION


class core_transaction; 
  
  rand core_cop_t cop;
  rand bit [31:0] addr;
  rand bit [2:0]  size; 
  rand bit [3:0]  be;
  rand bit [31:0] data;
  
  function new();
  endfunction 

  function string sprint();
    string str;
    str = {str, $sformatf("%0s addr=%0h size=%0d data=%0h ", cop.name(), addr, size, data)};
    if(this.is_wr()) begin
      str = {str, $sformatf("be=%0b", be)};
    end
    return(str);
  endfunction

  function bit is_wr();
    return(cop inside {WR, WRNC});
  endfunction


endclass

`endif
