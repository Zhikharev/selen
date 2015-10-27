module sx_1(
	input[10:0] imm_in,
	output[31:0] imm_out	
);

assign imm_out = imm_in[10] ? {{20{1'b1}},imm_in}: {{20{1'b0}},imm_in};

endmodule
