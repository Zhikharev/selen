// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : wb_slave_response_sequence.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_WB_SLAVE_RESPONSE_SEQUENCE
`define INC_WB_SLAVE_RESPONSE_SEQUENCE

class wb_slave_response_sequence extends uvm_sequence #(sl_wb_bus_item);

	`uvm_object_utils(wb_slave_response_sequence)

	function new(string name = "wb_slave_response_sequence");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

	task body();
		`uvm_info(get_full_name(), "is started",UVM_LOW)

		forever begin
			`uvm_create(req)
			assert(req.randomize()); // for $I size must be only 4 bytes, cop only RD
			`uvm_send(req)
			get_response(rsp);
		end

		`uvm_info(get_full_name(), "is completed",UVM_LOW)
	endtask

endclass

`endif