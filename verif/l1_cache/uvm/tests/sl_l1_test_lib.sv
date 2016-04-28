// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_test_lib.sv
// PROJECT        : Selen
// AUTHOR         :
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_L1_TEST_LIB
`define INC_L1_TEST_LIB

class l1_rd_test extends l1_base_test;
// ----------------------------------------------------------------------
// Передаются только команды чтения и некэшируемое чтение
// ----------------------------------------------------------------------
  `uvm_component_utils(l1_rd_test)

  function new(string name = "l1_rd_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.post_main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1d_agent.sequencer.post_main_phase", "default_sequence", sl_l1_rd_seq::type_id::get());
  endfunction

endclass

class l1_rd_after_wr_test extends l1_base_test;
// ----------------------------------------------------------------------
// Для кэша данных запросы передаются в последовательности
// запись - чтение по тому же адресу
// ----------------------------------------------------------------------
  `uvm_component_utils(l1_rd_after_wr_test)

  function new(string name = "l1_rd_after_wr_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.post_main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1d_agent.sequencer.post_main_phase", "default_sequence", sl_l1_rd_after_wr_seq::type_id::get());
  endfunction

endclass

class l1_random_test extends l1_base_test;
// ----------------------------------------------------------------------
// Передаются случайные транзакции
// ----------------------------------------------------------------------
  `uvm_component_utils(l1_random_test)

  function new(string name = "l1_random_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1i_agent.sequencer.post_main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"*l1d_agent.sequencer.post_main_phase", "default_sequence", sl_l1_base_seq::type_id::get());
  endfunction

endclass

`endif
