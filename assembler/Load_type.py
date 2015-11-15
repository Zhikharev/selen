#LW Rd 16(Rs1)
import Registers
from Service import Addr2Bin
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
        #Надо проверить есть ли elements[0] в self.codes
        result = ""
        addr = elements[-1]
        addr = addr.split("(")
        offset = int(addr[0])
        offset = Addr2Bin(offset, 12)
        result += offset
        addr[-1] = addr[-1][:-1]
        registers = Registers.Registers()
        result += registers.getAddress(addr[-1])
        result += self.funct3[elements[0]]
        result += registers.getAddress(elements[1])
        result += self.opcode
        return result
