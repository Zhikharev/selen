// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : fifo.v
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_FIFO
`define INC_FIFO

module fifo 
#(
	parameter WIDTH = 32,
	parameter DEPTH = 32
 )
(
  input 							clk, 
  input 							rst,
  input 							rd, 
  input 							wr,
  input [WIDTH-1:0] 	w_data,
  output 							empty, 
  output 							full,
  output [WIDTH-1:0] 	r_data

);
// signal declaration
reg [WIDTH-1:0] array_reg [DEPTH-1:0] ; // register array
reg [$clog2(DEPTH)-1:0] w_ptr_reg, w_ptr_next , w_ptr_succ;
reg [$clog2(DEPTH)-1:0] r_ptr_reg , r_ptr_next , r_ptr_succ ;

wire [$clog2(DEPTH)-1:0] w_ptr_succ;
wire [$clog2(DEPTH)-1:0] r_ptr_succ;

reg full_reg, empty_reg, full_next, empty_next;

wire wr_en;

// register file write operation
integer i;
always @(posedge clk,posedge rst) begin
	if(rst) begin
		for(i = 0; i < DEPTH; i = i + 1) begin
			array_reg[i] <= 0;
		end
	end
	else if(wr_en) begin 
		array_reg[w_ptr_reg] <= w_data;
	end
end

// register file read operation

assign r_data = array_reg[r_ptr_reg] ;

// write enabled only when FIFO is not full

assign wr_en = wr & ~full_reg;

// fifo control logic
// register for read and write pointers

always @(posedge clk , posedge rst) begin
	if (rst) begin
		w_ptr_reg <= 0;
		r_ptr_reg <= 0;
		full_reg  <= 1'b0;
		empty_reg <= 1'b1;
	end
	else  begin
		w_ptr_reg	<= 	w_ptr_next;
		r_ptr_reg	<= 	r_ptr_next;
		full_reg	<= 	full_next;
		empty_reg	<= 	empty_next;
	end
end

assign w_ptr_succ = w_ptr_reg + 1'b1;
assign r_ptr_succ = r_ptr_reg + 1'b1;

always @*  begin
	case ({wr,rd})
		// 2'b00 : no op
		2'b01: begin // read
			if (~empty_reg) // not empty
			begin
			  	r_ptr_next = r_ptr_succ;
			  	full_next = 1'b0;
			  	if (r_ptr_succ == w_ptr_reg) begin
			  		empty_next = 1'b1;
			  	end
			end
			  end  
		2'b10: begin // write
			if (~full_reg) begin //not full
				w_ptr_next = w_ptr_succ;
				empty_next = 1'b0;
				if (w_ptr_succ == r_ptr_reg) begin
					full_next = 1'b1;
				end	
			end
		end
		2'b11: begin // write and read
			if(~empty_reg) begin
				w_ptr_next = w_ptr_succ;
				r_ptr_next = r_ptr_succ;
			end
			else begin
				w_ptr_next = w_ptr_succ;
				empty_next = 1'b0;
				if (w_ptr_succ == r_ptr_reg) begin
					full_next = 1'b1;
				end
			end
		end
		default: begin
			// default: keep old values
			w_ptr_next	= w_ptr_reg;
			r_ptr_next	= r_ptr_reg;
			full_next	= full_reg;
			empty_next = empty_reg;
		end
		endcase
end

// output
assign full = full_reg ;
assign empty = empty_reg;

endmodule

`endif