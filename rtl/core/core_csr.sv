module core_csr(
	input clk,
	input	rst_n,
	input[(`CSR_WIDTH-1):0] csr_data_wrt,
	input[($clog2(`CSR_DEPTH):0] csr_addr,

	output[(`CSR_WIDTH-1):0] csr_data_out,
	output[(`TIMER_BITWISE-1):0] csr_time_out,
	);

	reg [(`CSR_WIDTH-1):0] regs [(`CSR_DEPTH-1):0];
	reg[(`TIMER_BITWISE-1):0] counter;
	integer i;
	always @(posedge clk) begin
		if(~rst_n) begin
			for(i=0;i<(`CSR_DEPTH-1);i++) begin
				regs[i] <= 0;
			end
		end
		else begin
			regs[csr_addr] <= csr_data_wrt;
		end
	end
always @(posedge clk) begin
	if(~rst_n) begin
		counter <= 0;
	end
	else begin
		counter <= counter_next;
	end
end
assign counter_next = counter + 1'b1;
endmodule