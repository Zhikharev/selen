// ----------------------------------------------------------------------------
// FILE NAME      : wb_slave_driver.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------
`ifndef INC_WB_SLAVE_DRIVER
`define INC_WB_SLAVE_DRIVER

class wb_slave_driver extends uvm_driver#(wb_item);

	`uvm_component_utils(wb_slave_driver)

  typedef virtual wb_if vif_t;
  vif_t vif;

  bit           m_random;
  int           m_delay;
  wb_agent_cfg cfg;

  function new (string name = "wb_slave_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
    uvm_config_db#(bit)::get(this, "", "m_random", m_random);
    if(uvm_config_db#(int)::get(this, "", "m_delay", m_delay)) begin
      if(m_random) `uvm_info("KNOBS", $sformatf("Max Delay (%0d) was set for: %0s", m_delay, get_full_name()), UVM_MEDIUM)
      else`uvm_info("KNOBS", $sformatf("Delay (%0d) was set for: %0s", m_delay, get_full_name()), UVM_MEDIUM)
    end
		if(!uvm_config_db#(wb_agent_cfg)::get(this, "", "cfg", cfg))
      `uvm_fatal("NOCFG", {"Configuration must be set for ", get_full_name(), "cfg"})
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
      @(vif.drv_s);
      if(!vif.rst) begin
        wb_item ret_item;
        if(vif.drv_s.cyc_o) begin
          seq_item_port.try_next_item(req);
          if(req != null) begin
            assert($cast(ret_item, req.clone()));
            ret_item.set_id_info(req);
            ret_item.accept_tr();
            repeat(rand_delay()) begin
              clear_interface();
              if(vif.rst) break;
            end
            void'(begin_tr(ret_item, "wb_slave_driver"));
            drive_item(ret_item);
            clear_interface();
            seq_item_port.item_done();
            end_tr(ret_item);
            seq_item_port.put_response(ret_item);
          end
          else
            clear_interface();
        end
        else
          reset_interface();
      end
      else
        reset_interface();
    end
  endtask

  // --------------------------------------------
  // TASK: reset_interface
  // --------------------------------------------
  task reset_interface();
    vif.drv.ack_i <= 0;
    vif.drv.dat_i <= 0;
    vif.drv.err_i <= 0;
    vif.drv.rty_i <= 0;
  endtask

  // --------------------------------------------
  // TASK: clear_interface
  // --------------------------------------------
  task clear_interface();
    bit [31:0] data;
    std::randomize(data);
    vif.drv.ack_i <= 0;
    vif.drv.dat_i <= data;
    vif.drv.stall_i <= 0;
    vif.drv.err_i <= 0;
    vif.drv.rty_i <= 0;
  endtask

  // --------------------------------------------
  // TASK: drive_item
  // --------------------------------------------
  task drive_item(wb_item item);
    vif.drv.ack_i   <= 1;
    if(vif.drv.we_o)
      vif.drv.dat_i <= item.data.pop_front();
    vif.drv.stall_i <= item.data.stall;
    vif.drv.err_i   <= item.err;
    vif.drv.rty_i   <= item.rty;
  endtask

endclass

`endif
