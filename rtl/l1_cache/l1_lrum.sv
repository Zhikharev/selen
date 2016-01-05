// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : l1_lrum.sv
// PROJECT        : Selen
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------
`ifndef INC_L1_LRUM
`define INC_L1_LRUM

module l1_lrum
(
	input 												clk,
	input 												rst_n,
	input 												req,
  input 	[`CORE_IDX_WIDTH-1:0] idx,
  input   [`L1_WAY_NUM]         tag_cmp_vect,
  input   [`L1_WAY_NUM]         ld_val_vect,
	output 												hit,
	output 	[`L1_WAY_NUM] 				way_vect
);

	reg  [`L1_WAY_NUM-1:0]   			lru_used_r[1<<`CORE_IDX_WIDTH-1:0];
 	wire [`L1_WAY_NUM-1:0] 				lru_used_next;
 	wire [`L1_WAY_NUM-1:0] 				lru_used_upd;

	wire [`L1_WAY_NUM-1:0] 				hit_vect;

	wire [`L1_WAY_NUM-1:0] 				lru_ev_aloc_way_vect;
	wire 													lru_is_evict;
	wire 													lru_evict_val;

  // ------------------------------------------------------
  // FUNCTION: ms1_vec
  // ------------------------------------------------------
  function [`WAY_NUM-1:0] ms1_vec;
    input [`WAY_NUM-1:0] vec; //when vec==0,ms1_vec=0!
    integer i,j;
    reg     res0;
    for (i=0; i<`WAY_NUM; i=i+1) 
      if (i<(`WAY_NUM-1)) begin
        res0=1'b0;
        for (j=i+1; j<`WAY_NUM; j=j+1) res0=res0|vec[j];
        ms1_vec[i]=vec[i]& ~res0;
      end
      else
        ms1_vec[i]=vec[i];
  endfunction

	assign hit_vect = ld_val_vect & tag_cmp_vect;
  assign hit = |hit_vect & req;
  assign way_vect = (hit) ? hit_vect : lru_ev_aloc_way_vect;
  assign lru_is_evict  = &ld_val_vect;
  assign lru_evict_val = ~hit & lru_is_evict;
  assign lru_ev_aloc_way_vect = (lru_used_r == 0) ? (1'b1 << (`L1_WAY_NUM-1)) : ms1_vec(~lru_used_r);
  assign lru_used_upd  = lru_used_r | way_vect;
  assign lru_used_next = (&lru_used_upd) ? way_vect : lru_used_upd;

  always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
    	lru_used_r <= 0;
    end else begin
    	if(req) begin
    		lru_used_r <= lru_used_next;
    	end
    end
  end

endmodule

`endif