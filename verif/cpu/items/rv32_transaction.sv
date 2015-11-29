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


class rv32_transaction; 
  function new ();
  endfunction 

  rand opcode_type opcode;
  rand bit[4:0] rd;
  rand bit[4:0] rs1;
  rand bit[4:0] rs2;
  rand bit[19:0] imm;
  //decode's vars
  opcode_type opcode_d;
  bit[4:0] rd_d;
  bit[4:0] rs1_d;
  bit[4:0] rs2_d;
  bit[19:0] imm_d;
  
  function string sprint();
    string str;
    return(str);
  endfunction

  function void decode(bit [31:0] data);
      localparam r = 7'b0000011;
      localparam r_i = 7'b1000011;
      localparam lui = 7'b1000011;
      localparam auipc = 7'b0110011;
      localparam sb = 7'b0010011;
      localparam jal = 7'b0001011;
      localparam s = 7'b0001111;
      localparam i = 7'b0000111;
      case(data[6:0])
        r:begin
          if(data[30] == 1'b1)begin
            case(data[14:12])
              3'b000:opcode_d = ADD;
              3'b001:opcode_d = SLT;
              3'b010:opcode_d = SLTU;
              3'b011:opcode_d = AND;
              3'b100:opcode_d = OR;
              3'b101:opcode_d = XOR;
              3'b110:opcode_d = SLL;
              3'b111:opcode_d = SRL;
            endcase;
          end
          else begin
            case(data[14:12])
              3'b000:opcode_d = SUB;
              3'b001:opcode_d = SRA;
              3'b010:opcode_d = AM;
              default: $display("error in decode method can't recognize function's field in R type when data[31] equels 1");
            endcase;
          end
          rs2_d = data[24:20];
          rs1_d = data[19:15];
          rd_d = data[11:7];
        end
        r_i:begin
          case(data[14:12])
            3'b000:opcode_d = ADDI;
            3'b001:opcode_d = SLTI;
            3'b010:opcode_d = ANDI;
            3'b011:opcode_d = ORI;
            3'b100:opcode_d = XORI;
            3'b101:opcode_d = SLLI;
            3'b110:opcode_d = SRLI;
            3'b111:opcode_d = SRAI;
          endcase;
          rd_d = data[11:7];
          rs1_d = data[19:15];
          imm_d = 20'b0;
          imm_d = data[31:20];
        end      
        lui:begin
          opcode_d = LUI;
          rd_d = data[11:7];
          imm_d = data[31:12];
        end
        auipc:begin
          opcode_d = AUIPC;
          rd_d = data[11:7];
          imm_d = data[31:12];
        end
        i:begin
          case(data[14:12])
            3'b000:opcode_d = JALR;
            3'b001:opcode_d = LW;
            3'b010:opcode_d = LH;
            3'b011:opcode_d = LHU;
            3'b100:opcode_d = LB;
            3'b101:opcode_d = LBU;
            default: $display("error in decode method can't recognize function's field in I type");
          endcase;
          
          rd_d = data[11:7];
          rs1_d = data[19:15];
          imm_d = 20'b0;
          imm_d = data[31:20];
        end
        s:begin
          case(data[14:12])
            3'b001:opcode_d = SW;
            3'b010:opcode_d = SH;
            3'b011:opcode_d = SB;
            default: $display("error in decode method can't recognize function's field in S type");
          endcase
          imm_d = 20'b0;
          imm_d = {data[31:25],data[11:7]};
          rs2_d = data[19:15];
        end      
      sb:begin
        case(data[14:12])
          3'b000:opcode_d = BEQ;
          3'b001:opcode_d = BNE;
          3'b010:opcode_d = BLT;
          3'b011:opcode_d = BLTU;
          3'b100:opcode_d = BGE;
          3'b101:opcode_d = BGEU;
          default: $display("error in decode method can't recognize function's field in SB type");
        endcase;
        rs2_d = data[24:20];
        rs1_d = data[19:15];
        imm_d = 20'b0;
        imm_d = {data[31],data[30:25],data[11:8],data[7]};            
      end
      endcase;
  endfunction

  function bit [31:0] encode();
    bit[31:0] instr;
    //R type
    if(opcode inside{ADD,SLT,SLTU,AND,OR,XOR,SLL,SRL,SUB,SRA,AM})begin
        instr[6:0] = 7'b0000011;
      if(opcode inside{SUB,SRA,AM})begin
        instr[31:25] = 7'b0100000;
      end
      else begin
        instr[31:25] = 7'b0000000;
      end
      instr[24:20] = rs2;
      instr[19:15] = rs1;
      instr[11:7] = rd;
      case(opcode)
        ADD:instr[14:12] = 3'b000;
        SLT:instr[14:12] = 3'b001;
        SLTU:instr[14:12] = 3'b010;
        AND:instr[14:12] = 3'b011;
        OR:instr[14:12] = 3'b100;
        XOR:instr[14:12] = 3'b101;
        SLL:instr[14:12] = 3'b110;
        SRL:instr[14:12] = 3'b111;
        SUB:instr[14:12] = 3'b000;
        SRA:instr[14:12] = 3'b001;
        AM:instr[14:12] = 3'b010;
      endcase;
    end 
    //R_I type  
    if(opcode inside{ADDI,SLTI,ANDI,ORI,XORI,SLLI,SRLI,SRAI})begin
     instr[6:0] = 7'b1000011;
     instr[31:20] = imm[11:0];
     instr[11:7] = rd;
     instr[19:15] = rs1; 
      case(opcode)
        ADDI:instr[14:12] = 3'b000;
        SLTI:instr[14:12] = 3'b001;
        ANDI:instr[14:12] = 3'b010;
        ORI:instr[14:12] = 3'b011;
        XORI:instr[14:12] = 3'b100;
        SLLI:instr[14:12] = 3'b101;
        SRLI:instr[14:12] = 3'b110;
        SRAI:instr[14:12] = 3'b111;
      endcase
    end
    if(opcode inside{LUI,AUIPC})begin
      instr[31:12] = imm;
      instr[14:11] = rd;
      if(opcode == LUI)begin
        instr[6:0] = 7'b0100011;
      end
      else begin
        instr[6:0] = 7'b0110011;
      end
    end
    if(opcode inside{JALR,LW,LH,LHU,LB,LBU})begin
      instr[6:0] = 7'b0000111;
      instr[11:7] = rd;
      instr[19:15] = rs1;
      instr[31:20] = imm[11:0];
      case(opcode)
        JALR:instr[14:12] = 3'b000;
        LW:instr[14:12] = 3'b001;
        LH:instr[14:12] = 3'b010;
        LHU:instr[14:12] = 3'b011;
        LB:instr[14:12] = 3'b100;
        LBU:instr[14:12] = 3'b101;
      endcase;
    end
    //STORE S type
    if(opcode inside{SW,SH,SB})begin
      instr[6:0] =7'b0001111;
      instr[11:7] = imm[4:0];
      instr[19:15] = rs2;
      instr[24:20] = rs2;
      instr[31:25] = imm[11:5];
      case(opcode)
        SW:instr[14:12] = 3'b000;
        SH:instr[14:12] = 3'b010;
        SB:instr[14:12] = 3'b011;
      endcase;
    end
    //BRNCH SB type
    if(opcode inside{BEQ,BNE,BLT,BLTU,BGE,BGEU})begin
      instr[6:0] =7'b0010011;
      instr[7] = imm[11];
      instr[11:8] = imm[4:1];
      instr[19:15] = rs1;
      instr[24:20] = rs2;
      instr[30:25] = imm[10:5];
      instr[31] = imm[11];
      case(opcode)
        BEQ:instr[14:12] = 3'b000;
        BNE:instr[14:12] = 3'b001;
        BLT:instr[14:12] = 3'b010;
        BLTU:instr[14:12] = 3'b100;
        BGE:instr[14:12] = 3'b101;
      endcase;
    end
    //UJ tyoe
    if(opcode == JAL) begin
      instr[6:0] = 7'b0001011;
      instr[11:7] = rd;
      instr[19:12] = imm[19:12];
      instr[20] = imm[11];
      instr[30:21] = imm[30:21];
      instr[31] = imm[20];
    end
  return(instr);
  endfunction

endclass

`endif
