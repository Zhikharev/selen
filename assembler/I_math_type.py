import Registers
from Service import Addr2Bin
class I_math_type:
    opcode = "1000011"
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
            imm = int(elements[-1])
            imm = Addr2Bin(imm, 12)
            result += imm
            registers = Registers.Registers()
            result += registers.getAddress(elements[-2])
            result += self.funct3[elements[0]]
            result += registers.getAddress(elements[1])
            result += self.opcode

        return result
