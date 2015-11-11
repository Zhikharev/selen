import R_type
import SB_type
import Load_type
import Store_type
labels = {"label" : 2278}
x = Store_type.Store_type()
st = x.getCode("SW $3 12($0)");
print(st)
print(len(st))
