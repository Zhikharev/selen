typedef enum bit[6:0] {
	R = 7'b0000011,
	R_I = 7'b1000011,
	U_LUI = 7'b0100011,
	U_AUIPC = 7'b0110011,
	SB = 7'b0010011,
	UJ = 7'b0001011,
	S = 7'b0001111,
	I = 7'b0000111
}rv32_opcode;

