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

class core_base_seq extends uvm_sequence #(rv32_transaction);

	`uvm_object_utils(core_base_seq)

	function new(string name = "core_base_seq");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

endclass

class core_alu_seq extends core_base_seq;

	`uvm_object_utils(core_alu_seq)

	function new(string name = "core_alu_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_alu_seq", UVM_MEDIUM)
		repeat(100) begin
			`uvm_create(req)
			assert(req.randomize() with {
				req.opcode inside {
					ADD, SLT, SLTU, AND, OR, XOR, SLL,
					SRL, SUB, SRA, AM, ADDI, SLTI, SLTIU,
					ANDI, ORI, XORI, SLLI, SRLI, SRAI};
    	});
			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "End of core_alu_seq", UVM_MEDIUM)
	endtask

endclass

class core_run_opcodes_seq extends core_base_seq;

	`uvm_object_utils(core_run_opcodes_seq)

	randc opcode_t cop;

	function new(string name = "core_run_opcodes_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_run_opcodes_seq", UVM_MEDIUM)
		repeat(100) begin
			`uvm_create(req)
			this.randomize();
			assert(req.randomize() with {
				req.opcode == cop;
			});
			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "End of core_run_opcodes_seq", UVM_MEDIUM)
	endtask

endclass