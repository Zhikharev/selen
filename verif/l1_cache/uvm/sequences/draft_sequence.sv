// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : draft_sequence.sv
// PROJECT        : Selen
// AUTHOR         : Maksim Kobzar
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_DRAFT_SEQUENCE
`define INC_DRAFT_SEQUENCE

class draft_sequence extends uvm_sequence #(sl_core_bus_item);

	`uvm_object_utils(draft_sequence)

	function new(string name = "draft_sequence");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

	task body();
		`uvm_info(get_full_name(), "is started",UVM_LOW)

		repeat(5) begin
			`uvm_create(req)
			assert(req.randomize() with {
				req.size == 4;
				req.addr[1:0] == 2'b0;
				req.addr < 20;
				req.cop == RD;
			}); // for $I size must be only 4 bytes, cop only RD
			`uvm_send(req)
			get_response(rsp);
		end

		`uvm_info(get_full_name(), "is completed",UVM_LOW)
	endtask

endclass

`endif