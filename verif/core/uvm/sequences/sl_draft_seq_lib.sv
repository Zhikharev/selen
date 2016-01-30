class draft_seq extends uvm_sequence #(rv32_transaction);

	`uvm_object_utils(draft_seq)

	function new(string name = "draft_seq");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

	task body();
		$display("hello");
		repeat(100) begin
			`uvm_create(req)
			assert(req.randomize());
			`uvm_send(req)
			get_response(rsp);
		end
	endtask

endclass