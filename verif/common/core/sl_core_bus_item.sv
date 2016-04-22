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

  constraint c_size {size inside {1, 2, 4};}

  function bit is_wr();
    return(cop inside {WR, WRNC});
  endfunction

  function bit is_nc();
    return(cop inside {RDNC, WRNC});
  endfunction

  function core_be_t get_be();
    case(this.size)
      1: get_be = 4'b0001 << this.addr[1:0];
      2: get_be = 4'b0011 << this.addr[1:0];
      4: get_be = 4'b1111;
      default: `uvm_fatal(get_full_name(), "Unxpected size!")
    endcase
  endfunction

endclass

`endif
