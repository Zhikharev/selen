#SLLI $Rd, Rs1, imm
import Registers
import Service
class I_shamt_type:
    opcode = "1000011"
    codes = [
        "SLLI",
        "SRLI",
        "SRAI"
    ]
    funct3 = {
        "SLLI" : "101",
        "SRLI" : "110",
        "SRAI" : "111"
    }
    imm = {
        "SLLI" : "0000000",
        "SRLI" : "0000000",
        "SRAI" : "0100000"
    }

    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            result += self.imm[elements[0]]
            result += Service.Addr2BinU(Service.Str2Num(elements[-1]), 5)
            registers = Registers.Registers()
            result += registers.getAddress(elements[-2])
            result += self.funct3[elements[0]]
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)

        return result
