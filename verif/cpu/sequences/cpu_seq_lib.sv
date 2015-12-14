// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_seq_lib.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_SEQ_LIB
`define INC_CPU_SEQ_LIB

class cpu_direct_seq extends base_seq;

  function new ();
    super.new();
  endfunction 

  function create_req_with_opcode(opcode_type cop);
    req = new();
    assert(req.randomize())
    else $fatal("Randomization failed!");
    req.opcode = cop;
    req_q.push_back(req);
  endfunction

  task body();
    $display("[%0t][SEQ] Start of 'cpu_direct_seq'", $time);
    create_req_with_opcode(ADD);
    create_req_with_opcode(SLT);
    $display ("[%0t][SEQ] End of 'cpu_draft_seq'", $time);  
  endtask 

endclass

class cpu_load_seq extends base_seq;

  function new ();
    super.new();
  endfunction 

  task body();
    $display("[%0t][SEQ] Start of 'cpu_load_seq'", $time);
    repeat(10) begin
      req = new();
      assert(req.randomize() with {
        req.opcode == LW;
        req.rd inside {[1:25]};
      })
      else $fatal("Randomization failed!");
      req_q.push_back(req);
    end
    $display ("[%0t][SEQ] End of 'cpu_load_seq'", $time);  
  endtask 

endclass

class cpu_test_seq extends base_seq;
	
	function new();
		super.new();
	endfunction
	
	
	task body();
		$display("[%0t][SEQ] Start of 'cpu_test_seq'", $time);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADDI;
		req.rd = 1;
		req.rs1 = 0;
		req.imm = 20'b1;
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req_q.push_back(req);
		req.opcode = ADDI;
		req.rd = 2;
		req.rs1 = 0;
		req.imm = 20'b1;
		req_q.push_back(req);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 3;
		req.rs1 = 1;
		req.rs2 = 2;
		req_q.push_back(req);
	endtask

endclass

class cpu_bp_seq extends base_seq;

	function new();
		super.new();
	endfunction
	
	task body();
		$display("[%0t][SEQ] Start of 'cpu_test_seq'", $time);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 10;
		req.rs1 = 1;
		req.rs2 = 2;
		req_q.push_back(req);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 3;
		req.rs1 = 10;
		req.rs2 = 2;
		req_q.push_back(req);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 5;
		req.rs1 = 1;
		req.rs2 = 3;
		req_q.push_back(req);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 0;
		req.rs1 = 0;
		req.rs2 = 0;
		req_q.push_back(req);
		req = new();
		assert(req.randomize())
		else $fatal("Randomization failed!");
		req.opcode = ADD;
		req.rd = 7;
		req.rs1 = 5;
		req.rs2 = 2;
		req_q.push_back(req);
	endtask
endclass


class cpu_ADDI_seq extends base_seq;

  function new ();
    super.new();
  endfunction 
	int i=0;
  task body();
    $display("[%0t][SEQ] Start of 'cpu_load_seq'", $time);
    repeat(32) begin
      req = new();
      assert(req.randomize())
      else $fatal("Randomization failed!");
      req.opcode = ADDI;
      req.rd = i;
      req.rs1 = 0;
      req.imm = i;	
      i = i +1;
      req_q.push_back(req);
    end
    $display ("[%0t][SEQ] End of 'cpu_load_seq'", $time);  
  endtask 

endclass
`endif
