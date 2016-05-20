// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_base_seq_lib.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_L1_BASE_SEQ_LIB
`define INC_SL_L1_BASE_SEQ_LIB

class sl_l1_base_seq extends uvm_sequence #(sl_l1_core_bus_item);

	int num_pkts;
	sl_l1_cfg l1_cfg;

	`uvm_object_utils(sl_l1_base_seq)
	`uvm_declare_p_sequencer(sl_core_sequencer)

	function new(string name = "sl_l1_base_seq");
  	super.new(name);
  	set_automatic_phase_objection(1);
	endfunction

	task pre_body();
		uvm_config_db#(int)::get(null, "*", "num_pkts", num_pkts);
		if(!uvm_config_db#(sl_l1_cfg)::get(p_sequencer, "*", "cfg", l1_cfg))
			`uvm_fatal("CFG", "Can't get l1_cfg!")
	endtask

	task body();
		`uvm_info(get_full_name(), "is started", UVM_MEDIUM)
		repeat(num_pkts) begin
			`uvm_create(req)
			req.cfg = l1_cfg;
			assert(req.randomize() with {
				if(p_sequencer.cfg.port == INSTR) req.size == 4;
				if(p_sequencer.cfg.port == INSTR) req.cop == RD;
				solve req.size before req.addr;
				(req.size == 4) -> (req.addr[1:0] == 2'b0);
				(req.size == 2) -> (req.addr[0] == 1'b0);
				req.addr inside {[l1_cfg.min_addr:l1_cfg.max_addr]};
			});
			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "is completed", UVM_MEDIUM)
	endtask

endclass

class sl_l1_rd_seq extends sl_l1_base_seq;

	`uvm_object_utils(sl_l1_rd_seq)

	function new(string name = "sl_l1_rd_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "is started", UVM_MEDIUM)
		repeat(num_pkts) begin
			`uvm_create(req)
			req.cfg = l1_cfg;
			assert(req.randomize() with {
				if(p_sequencer.cfg.port == INSTR) req.size == 4;
				if(p_sequencer.cfg.port == INSTR) req.cop == RD;
				solve req.size before req.addr;
				(req.size == 4) -> (req.addr[1:0] == 2'b0);
				(req.size == 2) -> (req.addr[0] == 1'b0);
				req.addr inside {[l1_cfg.min_addr:l1_cfg.max_addr]};
				req.cop inside {RD, RDNC};
			});
			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "is completed", UVM_MEDIUM)
	endtask

endclass

class sl_l1_rd_after_wr_seq extends sl_l1_base_seq;

	`uvm_object_utils(sl_l1_rd_after_wr_seq)

	function new(string name = "sl_l1_rd_after_wr_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "is started", UVM_MEDIUM)
		repeat(num_pkts) begin
			`uvm_create(req)
			req.cfg = l1_cfg;
			assert(req.randomize() with {
				solve req.size before req.addr;
				(req.size == 4) -> (req.addr[1:0] == 2'b0);
				(req.size == 2) -> (req.addr[0] == 1'b0);
				req.addr inside {[l1_cfg.min_addr:l1_cfg.max_addr]};
				req.cop inside {WR};
			});
			`uvm_send(req)
			get_response(rsp);
			`uvm_create(req)
			assert(req.randomize() with {
				req.addr == rsp.addr;
				req.size == rsp.size;
				req.cop inside {RD};
			});
			`uvm_send(req)
			get_response(rsp);

			#100;
			`uvm_send(req)
			get_response(rsp);

		end
		`uvm_info(get_full_name(), "is completed", UVM_MEDIUM)
	endtask

endclass

class sl_l1_cache_seq extends sl_l1_base_seq;

	`uvm_object_utils(sl_l1_cache_seq)

	function new(string name = "sl_l1_cache_seq");
  	super.new(name);
	endfunction

	task body();
		`uvm_info(get_full_name(), "is started", UVM_MEDIUM)
		repeat(num_pkts) begin
			`uvm_create(req)
			req.cfg = l1_cfg;
			assert(req.randomize() with {
				if(p_sequencer.cfg.port == INSTR) req.size == 4;
				if(p_sequencer.cfg.port == INSTR) req.cop == RD;
				solve req.size before req.addr;
				(req.size == 4) -> (req.addr[1:0] == 2'b0);
				(req.size == 2) -> (req.addr[0] == 1'b0);
				req.addr inside {[l1_cfg.min_addr:l1_cfg.max_addr]};
				req.cop inside {RD, WR};
			});

			`uvm_send(req)
			get_response(rsp);
		end
		`uvm_info(get_full_name(), "is completed", UVM_MEDIUM)
	endtask

endclass

`endif