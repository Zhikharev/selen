import Registers
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
        #Надо проверить есть ли elements[0] в self.codes
        result = ""
        #Тут возможна ошибка (надо проеверять есть ли метка в labels)
        addr = labels[elements[3]]
        addr = Addr2Bin(addr, 13)
        addr = addr[::-1]
        result += addr[12] + addr[5:11][::-1]
        registers = Registers.Registers()
        result += registers.getAddress(elements[2])
        result += registers.getAddress(elements[1])
        result += self.funct3[elements[0]]
        result += addr[1:5][::-1]
        result += addr[11]
        result += self.opcode;
        return result;



def Addr2Bin(num, length):
    i = bin(num)
    if (num < 0):
        i = i[3:]
    else:
        i = i[2:]
    #if len(i) > length: # Проверка на превышения лимита
        #ERROR("Ошибка при переводе числа " + num + ". Превышен лимит знаков")

    i = i.zfill(length-1)
    if num < 0:
        i = '1' + i
    else:
        i = '0' + i

    return i;
