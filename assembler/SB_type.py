#BEQ $Rs1, $Rs2, label
import Registers
import Service
class SB_type:
    opcode = "0010011"
    codes = [
        "BEQ",
        "BNE",
        "BLT",
        "BLTU",
        "BGE",
        "BGEU"
    ]
    funct3 = {
        "BEQ" : "000",
        "BNE" : "001",
        "BLT" : "010",
        "BLTU" : "011",
        "BGE" : "100",
        "BGEU" : "101"
    }
    def getCode(self, line, labels):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            #Тут возможна ошибка (надо проеверять есть ли метка в labels)
            elements = Service.DeleteCommas(elements)
            addr = labels[elements[3]]
            addr = Service.Addr2Bin(addr, 13)
            addr = addr[::-1]
            result += addr[12] + addr[5:11][::-1]
            registers = Registers.Registers()
            result += registers.getAddress(elements[2])
            result += registers.getAddress(elements[1])
            result += self.funct3[elements[0]]
            result += addr[1:5][::-1]
            result += addr[11]
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)

        return result
