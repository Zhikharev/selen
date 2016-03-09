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


class rv32_transaction extends uvm_sequence_item;

  rand opcode_t  opcode;
  rand bit[4:0]  rd;
  rand bit[4:0]  rs1;
  rand bit[4:0]  rs2;
  rand bit[31:0] imm;

  `uvm_object_utils_begin(rv32_transaction)
    `uvm_field_enum(opcode_t, opcode, UVM_DEFAULT)
    `uvm_field_int(rd,  UVM_DEFAULT)
    `uvm_field_int(rs1, UVM_DEFAULT)
    `uvm_field_int(rs2, UVM_DEFAULT)
    `uvm_field_int(imm, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

  constraint valid_opcodes {opcode != AM;}
  //constraint model_bugs {opcode != SRAI;}

  function string sprint();
    string str;
    str = {str, opcode.name()};
    str = {str, $sformatf(" rs1=%d rs2=%d rd=%d imm=%h", rs1, rs2, rd, imm)};
    return(str);
  endfunction

  function void decode(bit [31:0] data);
    rd  = data[11:7];
    rs1 = data[19:15];
    rs2 = data[24:20];
    case(data[6:0])
      `R_TYPE: begin
        case(data[31:25])
          7'b0000000: begin
            case(data[14:12])
              3'b000: opcode = ADD;
              3'b001: opcode = SLL;
              3'b010: opcode = SLT;
              3'b011: opcode = SLTU;
              3'b100: opcode = XOR;
              3'b101: opcode = SRL;
              3'b110: opcode = OR;
              3'b111: opcode = AND;
            endcase
          end
          7'b0100000: begin
            case(data[14:12])
              3'b000: opcode = SUB;
              3'b101: opcode = SRA;
              3'b010: opcode = AM;
              default: $error("Unknown [14:12] for R_TYPE, found 3'b%3b", data[14:12]);
            endcase
          end
          default: $error("Unknown [31:25] for R_TYPE");
        endcase
      end
      `I_TYPE: begin
        imm[11:0] = data[31:20];
        case(data[14:12])
          3'b000: opcode = ADDI;
          3'b010: opcode = SLTI;
          3'b011: opcode = SLTIU;
          3'b111: opcode = ANDI;
          3'b110: opcode = ORI;
          3'b100: opcode = XORI;
          3'b001: begin
            opcode = SLLI;
            if(data[31:25] != 7'b0000000) $error("Unexpected [31:25] for I_TYPE");
          end
          3'b101: begin
            case(data[31:25])
              7'b0000000: opcode = SRLI;
              7'b0100000: opcode = SRAI;
              default: $error("Unexpected [31:25] for I_TYPE");
            endcase
          end
        endcase
      end
      `LUI: begin
        imm = data[31:12];
        opcode = LUI;
      end
      `AUIPC: begin
        imm = data[31:12];
        opcode = AUIPC;
      end
      `SB_TYPE: begin
        imm[12] = data[31];
        imm[11] = data[7];
        imm[10:5] = data[30:25];
        imm[4:1] = data[11:8];
        case(data[14:12])
          3'b000: opcode = BEQ;
          3'b001: opcode = BNE;
          3'b100: opcode = BLT;
          3'b110: opcode = BLTU;
          3'b101: opcode = BGE;
          3'b111: opcode = BGEU;
          default: $error("Unexpected [14:12] for SB_TYPE");
        endcase
      end
      `UJ_TYPE: begin
        imm[20]    = data[31];
        imm[10:1]  = data[30:21];
        imm[11]    = data[20];
        imm[19:12] = data[19:12];
        opcode = JAL;
      end
      `JALR: begin
        opcode = JALR;
        imm[11:0] = data[31:20];
        if(data[14:12] != 3'b000) $error("Unexpected [14:12] for I_TYPE");
      end
      `LOAD: begin
        imm[11:0] = data[31:20];
        case(data[14:12])
          3'b010: opcode = LW;
          3'b001: opcode = LH;
          3'b101: opcode = LHU;
          3'b000: opcode = LB;
          3'b100: opcode = LBU;
          default: $error("Unexpected [14:12] for LOAD");
        endcase
      end
      `STORE: begin
        imm[11:5] = data[31:25];
        case(data[14:12])
          3'b010: opcode = SW;
          3'b001: opcode = SH;
          3'b000: opcode = SB;
          default: $error("Unexpected [14:12] for STORE");
        endcase
      end
      default: $error("Unexpected opcode");
    endcase
  endfunction

  function bit [31:0] encode();
    bit[31:0] instr;
    case(opcode)
      ADD:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      SLT:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b010; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      SLTU: begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b011; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      AND:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b111; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      OR:   begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b110; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      XOR:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b100; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      SLL:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b001; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end
      SRL:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0000000; end

      SUB:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0100000; end
      SRA:  begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0100000; end
      AM:   begin instr[6:0] = `R_TYPE; instr[11:7] = rd; instr[14:12] = 3'b010; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = 7'b0100000; end

      ADDI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      SLTI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b010; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      SLTIU:begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b011; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      ANDI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b111; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      ORI:  begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b110; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      XORI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b100; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end

      SLLI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b001; instr[19:15] = rs1; instr[24:20] = imm[4:0]; instr[31:25] = 7'b0000000; end
      SRLI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[24:20] = imm[4:0]; instr[31:25] = 7'b0000000; end
      SRAI: begin instr[6:0] = `I_TYPE; instr[11:7] = rd; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[24:20] = imm[4:0]; instr[31:25] = 7'b0100000; end

      LUI:  begin instr[6:0] = `LUI; instr[11:7] = rd; instr[31:12] = imm[31:12]; end
      AUIPC:begin instr[6:0] = `AUIPC; instr[11:7] = rd; instr[31:12] = imm[31:12]; end

      BEQ:  begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end
      BNE:  begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b001; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end 
      BLT:  begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b100; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end
      BLTU: begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b110; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end
      BGE:  begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end
      BGEU: begin instr[6:0] = `SB_TYPE; instr[7] = imm[11]; instr[11:8] = imm[4:1]; instr[14:12] = 3'b111; instr[19:15] = rs1; instr[24:20] = rs2; instr[30:25] = imm[10:5]; instr[31] = imm[12]; end

      JAL:  begin instr[6:0] = `UJ_TYPE; instr[11:7] = rd; instr[31:12] = {imm[20], imm[10:1], imm[11], imm[19:12]}; end

      JALR: begin instr[6:0] = `JALR; instr[11:7] = rd; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end

      LW:   begin instr[6:0] = `LOAD; instr[11:7] = rd; instr[14:12] = 3'b010; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      LH:   begin instr[6:0] = `LOAD; instr[11:7] = rd; instr[14:12] = 3'b001; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      LHU:  begin instr[6:0] = `LOAD; instr[11:7] = rd; instr[14:12] = 3'b101; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      LB:   begin instr[6:0] = `LOAD; instr[11:7] = rd; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end
      LBU:  begin instr[6:0] = `LOAD; instr[11:7] = rd; instr[14:12] = 3'b100; instr[19:15] = rs1; instr[31:20] = imm[11:0]; end

      SW:   begin instr[6:0] = `STORE; instr[11:7] = imm[4:0]; instr[14:12] = 3'b010; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = imm[11:5]; end
      SH:   begin instr[6:0] = `STORE; instr[11:7] = imm[4:0]; instr[14:12] = 3'b001; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = imm[11:5]; end
      SB:   begin instr[6:0] = `STORE; instr[11:7] = imm[4:0]; instr[14:12] = 3'b000; instr[19:15] = rs1; instr[24:20] = rs2; instr[31:25] = imm[11:5]; end
    endcase
    return(instr);
  endfunction

endclass

`endif
