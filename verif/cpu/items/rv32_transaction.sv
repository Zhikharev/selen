// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : rv32_transaction.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_RV32_TRANSACTION
`define INC_RV32_TRANSACTION
typedef enum int{ADD,SLT,SLTU,AND,OR,XOR,SLL,SRL,SUB,SRA,AM}R_type;
class rv32_transaction; 
	rand bit[2:0] funct3;	
  rand rv32_opcode opcode;
	rand bit[4:0] rd;
	rand bit[4:0] rs1;
	rand bit[4:0] rs2;
	rand bit funct7;
 	rand bit[11:0] imm_12;	
  rand bit[19:0] imm_20;
	bit[2:0] funct3_d;	
	rv32_opcode opcode_d;
	bit[4:0] rd_d;
	bit[4:0] rs1_d;
	bit[4:0] rs2_d;
	bit funct7_d;
	bit[11:0] imm_12_d;	
	bit[19:0] imm_20_d;
	int caunt; //caunter for R type 
  function new ();
  endfunction 

  function string sprint();
  	string str;
  	
  	// TODO

  	return(str);
  endfunction

  function void decode(bit [31:0] data);
			case(data[6:0])
				R:begin
					//opcode_d = data[6:0]; // there is a problem there 
					rd_d = data[11:7];
					funct3_d = data[14:12];
					rs1_d = data[20:16];
					rs2_d = data[25:21];
					funct7_d = data[30]; 
					if(funct3_d > 3'b111)begin
						caunt = {1,funct3};
					end
					else begin
						caunt =funct3;
					end
				end
				R_I:begin
					
				end			
			endcase;
  	// TODO

  endfunction

  function bit [31:0] encode();
  	bit [31:0] instr;
			case(opcode)
				R:begin instr = {0,funct7,5'b00000,rs2,rs1,funct3,rd,opcode};
				end
				R_I: begin 
					instr = {imm_12,rs1,funct3,rd,opcode};
				end
				U_LUI:begin
					instr = {imm_20,rd,opcode};
				end
				U_AUIPC:begin 
					instr= {imm_20,rd,opcode};
				end
				SB:begin
					instr = {imm_12[12],imm_12[10:5],rs2,rs1,funct3,imm_12[4:1],imm_12[11],opcode};
				end
				UJ: begin
					instr = {imm_20[20],imm_20[10:1],imm_20[11],imm_20[19:12],rd,opcode};
				end
				S: begin
					instr = {imm_12[11:5],rs1,rs2,funct3,imm_12[4:0],opcode};
				end
				I: begin
					instr = {imm_12,rs1,funct3,rd,opcode};
				end
		endcase;
  	// TODO

  	return(instr);
  endfunction

endclass

`endif
