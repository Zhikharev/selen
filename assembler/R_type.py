#XOR $Rd, $Rs1, $Rs2
import Registers
import Service
class R_type:
    opcode = "0110011"#"0000011"
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
        "SLT" : "010",#"001",
        "SLTU" : "011",#"010",
        "AND" : "111",#"011",
        "OR" : "110",#"100",
        "XOR" : "100",#"101",
        "SLL" : "001",#"110",
        "SRL" : "101",#"111",
        "SUB" : "000",
        "SRA" : "101",#"001",
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
