import R_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type
import JAL_instruction
import JALR_instruction

import Service

labels = {'metka': 217556 }
JAL = JAL_instruction.JAL_instruction()
JALR = JALR_instruction.JALR_instruction()
x = JALR.getCode('JALR $7, 15($0)')
print(x)
print(len(x))

data = "";
file_addr = input("Input file address: ")
pfile = open(file_addr);
code = Service.SplitToDierctives(pfile)
if ".CODE" not in code:
    Service.ERROR("CODE not found error!");

code[".CODE"] = code[".CODE"][:-1].split('\n')
if ".DATA" in code:
    code[".DATA"] = code[".DATA"][:-1].split('\n')
    code[".DATA"] = Service.ParseData(code[".DATA"])
    data = code[".DATA"]

s = Service.GetLabels(code[".CODE"])
code[".CODE"] = s[0];
code = code[".CODE"]
labels = s[1]
print(code)
print(data)
print(labels)
