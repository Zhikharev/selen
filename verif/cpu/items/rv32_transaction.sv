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


typedef enum bit[3:0] {ADD,SLT,SLTU,AND,OR,XOR,SLL,SRL,SUB,SRA,AM}R_type;
typedef enum bit[2:0] {ADDI,SLTI,ANDI,ORI,XORI,SLLI,SRLI,SRAI}R_I_type;
typedef enum bit[2:0] {BEQ,BNE,BLT,BLTU,BGE,BGEU}SB_type;
typedef enum bit[2:0] {SW,SH,sb} S_type;
typedef enum bit[2:0] {JALR,LW,LH,LHU,LB,LBU} I_type;
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
	bit[6:0] opcode_d;
	bit[4:0] rd_d;
	bit[4:0] rs1_d;
	bit[4:0] rs2_d;
	bit funct7_d;
	bit[11:0] imm_12_d;	
	bit[19:0] imm_20_d;
	int count; //caunter for R type 
  R_type r_type;
  R_I_type ri_type;
  SB_type sb_type;
  S_type  s_type;
  I_type  i_type;
  function new ();
  endfunction 

  function string sprint();
  	string str;
  		case(opcode)
				R:begin
					str = {r_type.name," ",rd_d," ",rs1_d," ",rs2_d};
				end  		
  			R_I:begin
					str = {ri_type.name," ",rd_d," ",imm_12_d," ",rs1_d};  			
  			end
  			U_LUI:begin
  				str = {"LUI"," ",rd_d," ",imm_20_d};	
  			end
  			U_AUIPC:begin
  				str = {"AUIPC"," ",rd_d," ",imm_20_d};
  			end
  			SB:begin
  				str = {sb_type.name," ",rs1_d," ",rs2_d," ",imm_12_d};
  			end
  			UJ:begin
  				str = {"JAL"," ",rd_d," ",imm_20_d};
  			end
  			S:begin
  				str = {s_type.name," ",rs2_d," ",rs1_d};
  			end
  			I:begin
  				str = {i_type.name," ",rd_d," ",rs1_d," ",imm_12_d};
  			end
  		endcase
  	return(str);
  endfunction

  function void decode(bit [31:0] data);
			case(data[6:0])
				R:begin
					opcode_d = data[6:0];
					rd_d = data[11:7];
					//funct3_d = data[14:12];
					rs1_d = data[20:16];
					rs2_d = data[25:21];
					funct7_d = data[30]; 
					imm_20_d = 20'bx;
					imm_12_d = 12'bx;
					if((funct3_d > 3'b111) && (funct7 == 1'b1))begin
						count = {1,funct3};
					end
					else begin
						count =funct3;
					end
					r_type = R_type'(count);			
				end
				R_I:begin
					opcode_d = data[6:0];
					rd_d = data[11:7];
					//funct3_d = data[14:12];
					count = data[14:12];
					ri_type = R_I_type'(count);
					rs1_d = data[20:16];
					rs2_d = 5'bx;
					funct7_d = 1'bx; 
					imm_20_d = 20'bx;
					imm_12_d = data[31:21];
				end			
				U_LUI:begin
					opcode_d = data[6:0];
					rd_d = data[11:7];
					imm_20_d = data[31:12];
					imm_12_d = 12'bx;
				end
			endcase;
  		U_AUIPC:begin
				opcode_d = data[6:0];
				rd_d = data[11:7];
				imm_20_d = data[31:12];
				imm_12_d = 12'bx;
  		end
  		SB:begin
  			opcode_d = data[6:0];
  			imm_12 = {data[31],data[7],data[30:25],data[11:8]};
  			rs1_d = data[20:14];
  			rs2_d = data[25:21];
  			count = data[14:12];
  			sb_type = SB_type'(count);
  			imm_20_d = 20'bx;
  		end
  		UJ:begin
  			opcode_d = data[6:0];
  			rd_d = data[11:7];
  			imm_20_d = {data[31],data[20:12],data[21],data[30:20]};
  			imm_12_d = 12'bx;
  		end
  		S:begin
  			opcode_d = data[6:0];
  			count = data[14:12];
  			s_type = S_type'(count);			
  			rs1_d = data[24:20];
  			rs2_d = data[19:15];
  			imm_12_d = {data[31:25],data[11:7]};
  		end
  		I:begin
  			opcode_d = data[6:0];
  			rd_d = data[11:7];
  			count = data[14:12];
				i_type = I_type'(count);
				rs1_d = data[19:15];
				imm_12_d = data[31:20];
				imm_20_d = 20'bx;  		
  		end
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
					instr = {imm_12[12],imm_12[10:5],rs2,rs1,funct3,imm_12[4:1],imm_12[11],opcode};//
				end
				UJ: begin
					instr = {imm_20[20],imm_20[10:1],imm_20[11],imm_20[19:12],rd,opcode};//
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
