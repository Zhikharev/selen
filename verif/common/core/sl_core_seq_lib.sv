// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_seq_lib.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_SEQ_LIB
`define INC_SL_CORE_SEQ_LIB


class sl_core_base_seq extends uvm_sequence #(sl_core_bus_item);

  `uvm_object_utils(sl_core_base_seq)

  function new(string name = "sl_core_base_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
endclass

class sl_core_slave_random_seq extends sl_core_base_seq;

  `uvm_object_utils(sl_core_slave_random_seq)

  function new(string name = "sl_core_slave_random_seq");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  task body();
    `uvm_info(get_full_name(), "Start of sl_core_slave_random_seq", UVM_MEDIUM)
    forever begin
      `uvm_create(req)
      assert(req.randomize());
      `uvm_send(req)
      get_response(rsp);
    end
    `uvm_info(get_full_name(), "End of sl_core_slave_random_seq", UVM_MEDIUM)
  endtask

endclass

`endif
