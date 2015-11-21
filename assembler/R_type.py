import Registers
import Service
class R_type:
    opcode = "0000011"
    codes = [
        "ADD",
        "SLT",
        "SLTU",
        "AND",
        "OR",
        "XOR",
        "SLL",
        "SRL",
        "SUB",
        "SRA",
        "AM"
    ]
    funct3 = {
        "ADD" : "000",
        "SLT" : "001",
        "SLTU" : "010",
        "AND" : "011",
        "OR" : "100",
        "XOR" : "101",
        "SLL" : "110",
        "SRL" : "111",
        "SUB" : "000",
        "SRA" : "001",
        "AM" : "010"
    }
    funct7 = {
        "SUB" : "0100000",
        "SRA" : "0100000",
        "AM" : "0100000"
    }
    def getCode(self, line):
        elements = line.split(" ")
        result = ""
        if elements[0] in self.codes:
            elements = Service.DeleteCommas(elements)
            result = self.funct7.get(elements[0], "0000000")
            registers = Registers.Registers()
            result += registers.getAddress(elements[-1])
            result += registers.getAddress(elements[-2])
            result += self.funct3[elements[0]]
            result += registers.getAddress(elements[1])
            result += self.opcode
        else:
             Service.ERROR("Error: " + Service.InstNotFound + "in line: " + line)

        return result
