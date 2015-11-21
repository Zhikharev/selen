import R_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type

import Service

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
