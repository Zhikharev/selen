// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_bus_item.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_BUS_ITEM
`define INC_SL_CORE_BUS_ITEM


class sl_core_bus_item extends uvm_sequence_item;

  rand core_cop_t  cop;
  rand core_size_t size;
  rand core_addr_t addr;
  rand core_data_t data;

  `uvm_object_utils_begin(sl_core_bus_item)
    `uvm_field_enum(core_cop_t, cop, UVM_DEFAULT)
    `uvm_field_int(size,  UVM_DEFAULT)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

  function bit is_wr();
    return(cop inside {WR, WRNC});
  endfunction

  function bit is_nc();
    return(cop inside {RDNC, WRNC});
  endfunction
endclass

`endif
