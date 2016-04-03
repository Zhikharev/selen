// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_core_master_driver.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL : maksim.s.kobzar@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : Driver with core interface
// ----------------------------------------------------------------------------

`ifndef INC_SL_CORE_MASTER_DRIVER
`define INC_SL_CORE_MASTER_DRIVER

class sl_core_master_driver extends uvm_driver #(sl_core_bus_item);

  virtual core_if vif;
  sl_core_bus_item tr_item;
  sl_core_agent_cfg cfg;

  `uvm_component_utils(sl_core_master_driver)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual core_if)::get(this, "" ,"vif", vif))
    else `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(),".vif"});
    assert(uvm_config_db#(sl_core_agent_cfg)::get(this, "" ,"cfg", cfg))
    else `uvm_fatal("NOCFG", {"CFG must be set for: ", get_full_name(),".cfg"});
  endfunction

  function int rand_delay();
    int delay;
    if(cfg.drv_fixed_delay) begin
      delay = cfg.drv_delay_max;
    end
    else begin
      std::randomize(delay) with {
        delay dist {0 :/ 90, [1:cfg.drv_delay_max] :/ 10};
      };
    end
    return(delay);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.drv_m);
      if(!vif.rst) begin
        seq_item_port.try_next_item(tr_item);
        if(tr_item != null) begin
          sl_core_bus_item ret_item;
          assert($cast(ret_item, tr_item.clone()));
          ret_item.set_id_info(tr_item);
          ret_item.accept_tr();
          drive_item(ret_item);
          seq_item_port.item_done();
          seq_item_port.put_response(ret_item);
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
    vif.req_val   <= 1'b0;
    vif.req_cop   <= 3'h0;
    vif.req_size  <= 3'h0;
    vif.req_addr  <= 32'h0;
    vif.req_wdata <= 32'h0;
  endtask

  // Clear interface
  task clear_interface();
    vif.req_val   <= 1'b0;
    vif.req_cop   <= 3'h0;
    vif.req_size  <= 3'h0;
    vif.req_addr  <= 32'h0;
    vif.req_wdata <= 32'h0;
  endtask

  // Drive item
  task drive_item(sl_core_bus_item ret_item);
    vif.req_val <= 1'b1;
    vif.req_cop <= ret_item.cop;
    vif.req_size <= ret_item.size;
    vif.req_addr <= ret_item.addr;
    if(ret_item.cop == 3'b001)
      vif.req_wdata <= ret_item.data;
    while(!vif.req_ack)
      @(vif.drv_m);
  endtask

endclass

`endif