import R_type
import SB_type
import Load_type
import Store_type
import I_math_type
import I_shamt_type
labels = {"label" : 2278}
x = I_shamt_type.I_shamt_type()
st = x.getCode("SRAI $15 $RA 4");
print(st)
print(len(st))
