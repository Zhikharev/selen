import R_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type
import JAL_instruction
import JALR_instruction

import Service

R_t = R_type.R_type()
SB_t = SB_type.SB_type()
L_t = Load_type.Load_type()
S_t = Store_type.Store_type()
Im_t = I_math_type.I_math_type()
Is_t = I_shamt_type.I_shamt_type()

cfg = Service.readConfig("config.cfg")
start_addr = 0;
if "start_addr" in cfg:
    start_addr = Service.Str2Num(cfg["start_addr"])
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
    dataK = code[".DATA"][0]
    dataD = code[".DATA"][1]

s = Service.GetLabels(code[".CODE"])
code[".CODE"] = s[0];
code = code[".CODE"]
labels = s[1]

binary = ""
for line in code:
    instr = line.split(" ")
    last = instr[-1]
    instr = instr[0]
    if instr in R_t.codes:
        binary += R_t.getCode(line) + "\n"
    elif instr in Im_t.codes:
        binary += Im_t.getCode(line) + "\n"
    elif instr in Is_t.codes:
        binary += Is_t.getCode(line) + "\n"
    elif instr in SB_t.codes:
        if last in labels:
            nlabel = labels[last]
            binary += SB_t.getCode(line, {last: nlabel - len(binary)/8}) + "\n"
        else:
            Service.ERROR("Error label not found, in lane: " + line);
    elif instr in L_t.codes:
        binary += L_t.getCode(line) + "\n"
    elif instr in S_t.codes:
        binary += S_t.getCode(line) + "\n"

print(binary)
