# SW Rs1 8(Rs2)
import Registers
import Service
class Store_type:
    opcode = "0001111"
    codes = [
        "SW",
        "SH",
        "SB"
    ]
    funct3 = {
        "SW" : "001",
        "SH" : "010",
        "SB" : "011"
    }
    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            addr = elements[-1][:-1]
            addr = addr.split("(")
            offset = Service.Str2Num(addr[0])
            offset = Service.Addr2Bin(offset, 12)
            offset = offset[::-1]
            result += offset[5:][::-1]
            registers = Registers.Registers()
            result += registers.getAddress(elements[1])
            result += registers.getAddress(addr[-1])
            result += self.funct3[elements[0]]
            result += offset[0:5][::-1]
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + lines)
        return result
