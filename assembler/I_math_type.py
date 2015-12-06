#ADDI $Rd, $Rs1, imm
import Registers
import Service
class I_math_type:
    opcode = "0100011"
    codes = [
        "ADDI",
        "SLTI",
        "ANDI",
        "ORI",
        "XORI"
    ]
    funct3 = {
        "ADDI" : "000",
        "SLTI" : "001",
        "ANDI" : "010",
        "ORI" : "011",
        "XORI" : "100"
    }

    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            imm = Service.Str2Num(elements[-1])
            imm = Service.Addr2Bin(imm, 12)
            result += imm
            registers = Registers.Registers()
            result += registers.getAddress(elements[-2])
            result += self.funct3[elements[0]]
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)

        return result
