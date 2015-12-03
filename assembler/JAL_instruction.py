#JAL $Rd, label
import Registers
import Service
class JAL_instruction:
    opcode = "0001011"
    codes = [
        "JAL"
    ]
    def getCode(self, line, labels):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            addr = labels[elements[-1]]
            addr = Service.Addr2BinU(addr, 21)
            addr = addr[::-1]
            result += addr[20]
            result += addr[1:11][::-1]
            result += addr[11]
            result += addr[12:20][::-1]
            registers = Registers.Registers()
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + lines)
        return result
