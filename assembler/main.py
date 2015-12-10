import R_type
import U_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type
import JAL_instruction
import JALR_instruction

import Service

R_t = R_type.R_type()
U_t = U_type.U_type();
SB_t = SB_type.SB_type()
L_t = Load_type.Load_type()
S_t = Store_type.Store_type()
Im_t = I_math_type.I_math_type()
Is_t = I_shamt_type.I_shamt_type()
Jal = JAL_instruction.JAL_instruction()
Jalr = JALR_instruction.JALR_instruction()

cfg = Service.readConfig("config.cfg")
start_addr = 0;
if "start_addr" in cfg:
    start_addr = Service.Str2Num(cfg["start_addr"])
data = "";
file_addr = "in.ass"
if "in_file_addr" in cfg:
    file_addr = cfg["in_file_addr"]
pfile = open(file_addr);
code = Service.SplitToDierctives(pfile)
if ".CODE" not in code:
    Service.ERROR("CODE not found error!");
dataD = ""
dataK = ""
code[".CODE"] = code[".CODE"][:-1].split('\n')
if ".DATA" in code:
    code[".DATA"] = code[".DATA"][:-1].split('\n')
    code[".DATA"] = Service.ParseData(code[".DATA"])
    dataK = code[".DATA"][0]
    dataD = code[".DATA"][1]

ccode = Service.GetLabels(code[".CODE"])
code[".CODE"] = ccode[0];
code = code[".CODE"]
labels = ccode[1]

code_end_addr = len(code) * 4;
binary = ""
for line in code:
    instr = line.split(" ")
    last = instr[-1]
    instr = instr[0]
    if instr in R_t.codes:
        binary += R_t.getCode(line)
    elif instr in Im_t.codes:
        binary += Im_t.getCode(line)
    elif instr in Is_t.codes:
        binary += Is_t.getCode(line)
    elif instr in U_t.codes:
        binary += U_t.getCode(line)
    elif instr in SB_t.codes:
        if last in labels:
            nlabel = labels[last]
            binary += SB_t.getCode(line, {last: nlabel - len(binary)/8})
        else:
            Service.ERROR("Error label not found, in lane: " + line);
    elif instr in Jal.codes:
        Jal.getCode(line, labels)
    elif instr in Jalr.codes:
        if last in labels:
            nlabel = labels[last]
            binary += Jalr.getCode(line, {last: nlabel - len(binary)/8})
        else:
            Service.ERROR("Error label not found, in lane: " + line);
    elif instr in L_t.codes:
        binary += L_t.getCode(line)
    elif instr in S_t.codes:
        binary += S_t.getCode(line)

if "out_file" in cfg:
    fout = open(cfg["out_file"], "wb")
    Service.WriteBinary(fout, binary + dataD)
    fout.close()

if "out_filef" in cfg:
    fout = open(cfg["out_filef"], "wb")
    cur = 0
    fbin = ""
    dheader = ""
    if "data_header" in cfg:
        dheader = cfg["data_header"]
    binary += dataD;
    print(binary)
    while cur < len(binary):
        c = binary[cur:cur+32]
        fbin += dheader + c
        cur += 32
    if "start_addr" in cfg:
        fbin = cfg["start_addr"] + fbin
    if "start_addr_header" in cfg:
        fbin = cfg["start_addr_header"] + fbin
    if "start_header" in cfg:
        fbin = cfg["start_header"] + fbin
    if "end_header" in cfg:
        fbin += cfg["end_header"]
    Service.WriteBinary(fout, fbin)
    fout.close()
