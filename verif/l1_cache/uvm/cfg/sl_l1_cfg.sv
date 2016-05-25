// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// FILE NAME      : sl_l1_cfg.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhikharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    :
// ----------------------------------------------------------------------------

`ifndef INC_SL_L1_CFG
`define INC_SL_L1_CFG

class sl_l1_cfg extends uvm_object;

	rand l1_num_t tags_num;
	rand l1_num_t idx_num;

	rand l1_addr_t min_addr;
	rand l1_addr_t max_addr;

	l1_addr_t min_nc_addr;
	l1_addr_t max_nc_addr;

	`uvm_object_utils_begin(sl_l1_cfg)
		`uvm_field_enum(l1_num_t, tags_num, UVM_DEFAULT)
		`uvm_field_enum(l1_num_t, idx_num, 	UVM_DEFAULT)
		`uvm_field_int (max_addr,           UVM_DEFAULT)
		`uvm_field_int (min_addr,           UVM_DEFAULT)
	`uvm_object_utils_end

	constraint c_solve_order {
		solve idx_num  before tags_num;
		solve tags_num before min_addr;
		solve min_addr before max_addr;
	}

	constraint c_idx_num {
		idx_num dist {LOW := 50, MEDIUM := 30, HIGH := 20};
	}

	constraint c_tag_addr {
		(tags_num == LOW) 	 -> (max_addr.tag - min_addr.tag) inside {[1:3]};
		(tags_num == MEDIUM) -> (max_addr.tag - min_addr.tag) inside {[4:16]};
		(tags_num == HIGH) 	 -> (max_addr.tag - min_addr.tag) > 16;
	}

	constraint c_idx_addr {
		(idx_num == LOW) 	  -> max_addr.idx == min_addr.idx;
		(idx_num == MEDIUM) -> (max_addr.idx - min_addr.idx) inside {[1:2]};
		(idx_num == HIGH) 	-> (max_addr.idx - min_addr.idx) inside {[3:5]};
	}

	constraint c_addr {
		max_addr > min_addr;
	}


	function new(string name = "sl_l1_cfg");
		super.new(name);
	endfunction

endclass
`endif
