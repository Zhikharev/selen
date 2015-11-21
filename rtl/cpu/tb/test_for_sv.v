module test ();
	reg imm_in;
	wire imm_out;
initial begin
	imm_in = {5{2'b10}};
	#5
	imm_in = {5{2'b01}};
end


endmodule
