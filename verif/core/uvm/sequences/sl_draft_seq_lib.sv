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

	int num_pkts;

	function new(string name = "core_base_seq");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

	task pre_body();
		uvm_phase phase = get_starting_phase();
		phase.phase_done.set_drain_time(this, 500);
		uvm_config_db#(int)::get(null, get_full_name(), "num_pkts", num_pkts);
	endtask

endclass

class core_alu_seq extends core_base_seq;

	`uvm_object_utils(core_alu_seq)

	function new(string name = "core_alu_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_alu_seq", UVM_MEDIUM)
		repeat(num_pkts) begin
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

class core_ld_st_seq extends core_base_seq;

// Нужно следить, чтобы диапазоны адресов инструкций и данных
// не пересекались

	`uvm_object_utils(core_ld_st_seq)

	function new(string name = "core_ld_st_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_ld_st_seq", UVM_MEDIUM)

		li(32'hfff0_0000, 1);

		repeat(num_pkts) begin
			`uvm_create(req)
			assert(req.randomize() with {
				solve req.opcode before req.imm;
				req.rs1 == 1;
				req.imm inside {[0:32'hA000]};
				req.opcode inside {LW, SW} -> (req.imm % 4) == 0;
				req.opcode inside {LH, LHU, SH} -> (req.imm % 2) == 0;
				req.opcode inside {
					LW,	LH,	LHU, LB, LBU,
					SW, SH, SB};
    	});
			`uvm_send(req)
			get_response(rsp);

			if(req.rd == 1) begin
				li(32'hfff0_0000, 1);
			end

		end
		`uvm_info(get_full_name(), "End of core_ld_st_seq", UVM_MEDIUM)
	endtask

	task li(bit [31:0] imm, int rd);
		`uvm_create(req)
		req.opcode = LUI;
		req.rd = rd;
		req.imm = imm;
		`uvm_send(req)
		get_response(rsp);
	endtask

endclass

class core_jmp_seq extends core_base_seq;

	`uvm_object_utils(core_jmp_seq)
	rv32_transaction mem_req;

	function new(string name = "core_jmp_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_jmp_seq", UVM_MEDIUM)
		repeat(num_pkts) begin
			`uvm_create(req)
			assert(req.randomize() with {
				solve req.opcode before req.imm;
				req.opcode inside {JAL, JALR};
				req.opcode == JAL -> ((req.imm % 4) == 0);
    	});
    	if(req.opcode == JALR) begin
    		// Загружаем случайные данные из памяти в регистр
    		// Выравниваем через логические операции по границе
    		// 4 байт
    		`uvm_create(mem_req)
    		mem_req.opcode = LW;
    		mem_req.rs1 = 0;
    		mem_req.rd = req.rs1;
    		mem_req.randomize(imm);
				`uvm_send(mem_req)
				get_response(rsp);
    	end
			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "End of core_jmp_seq", UVM_MEDIUM)
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
		repeat(num_pkts) begin
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

class core_raw_seq extends core_base_seq;

	`uvm_object_utils(core_raw_seq)

	rv32_transaction raw;

	function new(string name = "core_raw_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "Start of core_raw_seq", UVM_MEDIUM)
		`uvm_create(req)
		assert(req.randomize());
		`uvm_send(req)
		get_response(rsp);
		`uvm_create(raw)
		assert(raw.randomize() with {
			(raw.rs1 == req.rd) || (raw.rs2 == req.rd);
		});
		`uvm_send(raw)
		get_response(rsp);
		`uvm_info(get_full_name(), "End of core_raw_seq", UVM_MEDIUM)
	endtask

endclass