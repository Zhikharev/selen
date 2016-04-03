// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME        : rst_base_seq.sv
// PROJECT          : Selen
// AUTHOR           : Grigoriy Zhiharev
// AUTHOR'S EMAIL   :
// ----------------------------------------------------------------------------
// DESCRIPTION      :
// ----------------------------------------------------------------------------

`ifndef INC_RST_BASE_SEQ
`define INC_RST_BASE_SEQ

class rst_base_seq extends uvm_sequence #(rst_transfer);

    `uvm_object_utils(rst_base_seq)

   function new(string name ="rst_base_seq");
        super.new(name);
    endfunction

   	task pre_body();
        if(starting_phase != null) begin
            starting_phase.raise_objection(this, get_name());
        end

    endtask

  	task post_body();
         if (starting_phase!=null) begin
            starting_phase.drop_objection(this, get_name());
        end
    endtask

    task body();
        `uvm_info(get_name(), "Start of 'rst_base_seq'", UVM_HIGH)
        `uvm_info(get_name(), "Executing system reset...", UVM_LOW)
        `uvm_create(req)
        assert(req.randomize())
        else `uvm_fatal(get_name(), "Randomization failed!")
        `uvm_send(req)
        get_response(rsp);
        `uvm_info(get_name(), "End of 'rst_base_seq'", UVM_HIGH)
    endtask

endclass

`endif