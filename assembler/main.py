import R_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type

import Service

file_addr = input("Input file address: ")
pfile = open(file_addr);
code = Service.SplitToDierctives(pfile)
if ".code" not in code:
    Service.ERROR("Code not found error!");

code[".code"] = code[".code"][:-1].split('\n')
if ".data" in code:
    code[".data"] = code[".data"][:-1].split('\n')

print(code[".code"], code[".data"])
