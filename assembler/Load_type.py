#LW Rd 16(Rs1)
import Registers
import Service
class Load_type:
    opcode = "0000111"
    codes = [
        "LW",
        "LH",
        "LHU",
        "LB",
        "LBU"
    ]
    funct3 = {
        "LW" : "001",
        "LH" : "010",
        "LHU" : "011",
        "LB" : "100",
        "LBU" : "101"
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
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)

        return result
