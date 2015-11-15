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

def Addr2BinU(num, length):
    i = bin(num)
    if (num < 0):
        i = i[3:]
    else:
        i = i[2:]
    #if len(i) > length: # Проверка на превышения лимита
        #ERROR("Ошибка при переводе числа " + num + ". Превышен лимит знаков")

    i = i.zfill(length)
    return i;

def DeleteCommas(elements):
    for i in range(len(elements)):
        if elements[i].endswith(","):
            elements[i] = elements[i][:-1]

    return elements;
