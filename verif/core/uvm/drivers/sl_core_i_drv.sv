// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_i_drv.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : Driver with core interface for instruction port
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_I_DRV
`define INC_SL_CORE_I_DRV

class sl_core_i_drv extends uvm_driver #(rv32_transaction);

  virtual core_if vif;
  rv32_transaction tr_item;

  `uvm_component_utils(sl_core_i_drv)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual core_if)::get(this, "" ,"vif", vif))
    else `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(),".vif"});
  endfunction

  function int rand_delay();
    int delay;
    std::randomize(delay) with {
      delay dist {0 :/ 90, [5:20] :/ 10};
    };
    return(delay);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.mon);
      if(!vif.rst) begin
        if(vif.drv.req_val) begin
          seq_item_port.try_next_item(tr_item);
          if(tr_item != null) begin
            rv32_transaction ret_item;
            assert($cast(ret_item, tr_item.clone()));
            ret_item.set_id_info(tr_item);
            ret_item.accept_tr();
            repeat(rand_delay()) begin
              clear_interface();
              @(vif.mon);
            end
            drive_item(ret_item);
            seq_item_port.item_done();
            seq_item_port.put_response(ret_item);
          end
          else
            clear_interface();
        end
        else
          clear_interface();
      end
      else
        reset_interface();
    end
  endtask

  // Reset interface
  task reset_interface();
    vif.req_ack <= 0;
    vif.req_ack_data <= 0;
  endtask

  // Clear interface
  task clear_interface();
    vif.req_ack <= 0;
  endtask

  // Drive item
  task drive_item(rv32_transaction item);
    `uvm_info("DRV(I)", item.sprint(), UVM_LOW)
    vif.req_ack <= 1'b1;
    vif.req_ack_data <= item.encode();
  endtask

endclass

`endif