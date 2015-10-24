class Registers:
    registers = {
    "$0" : "00000",
    "$a" : "00000",
    "$1" : "00001",
    "$b" : "00001",
    "$2" : "00010",
    "$c" : "00010"
    }
    def getAddress(self, reg):
        if reg in self.registers:
            return self.registers[reg]
