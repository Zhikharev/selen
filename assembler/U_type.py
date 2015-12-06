import Registers
import Service
class U_type:
    opcode = "0100011"
    codes = [
        "LUI",
        "AUIPC"
    ]
    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            imm = Service.Str2Num(elements[-1])
            imm = Service.Addr2BinU(imm, 20)
            result += imm
            registers = Registers.Registers()
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
            Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)
        return result;
        
