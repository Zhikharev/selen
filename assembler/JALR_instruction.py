#JALR $Rd, 8($Rs1)
import Registers
import Service
class JALR_instruction:
    opcode = "0000111"
    codes = [
        "JALR"
    ]
    funct3 = {
        "JALR" : "000",
    }
    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            addr = elements[-1]
            addr = addr.split("(")
            offset = Service.Str2Num(addr[0])
            offset = Service.Addr2Bin(offset, 12)
            result += offset
            addr[-1] = addr[-1][:-1]
            registers = Registers.Registers()
            result += registers.getAddress(addr[-1])
            result += self.funct3[elements[0]]
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + lines)
        return result
