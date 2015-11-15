InstNotFound = "Instruction NOT FOUND "
RegNotFound = "Register NOT FOUND"
#Перевод числа в бинарную строку со знаковым разрешением
def Addr2Bin(num, length):
    i = bin(num)
    if (num < 0):
        i = i[3:]
    else:
        i = i[2:]

    if len(i) > length: # Проверка на превышение лимита
        Service.ERROR("Error while translate number " + num + ". Length's limit exceeded.")

    i = i.zfill(length-1)
    if num < 0:
        i = '1' + i
    else:
        i = '0' + i

    return i;
#Перевод числа в бинарную строку без знакового разрешения
def Addr2BinU(num, length):
    i = bin(num)
    if (num < 0):
        i = i[3:]
    else:
        i = i[2:]
    if len(i) > length: # Проверка на превышение лимита
        Service.ERROR("Error while translate number " + num + ". Length's limit exceeded.")

    i = i.zfill(length)
    return i;
#Перевод строки в число,с учетом системы счисления
def Str2Num(strnum):
    num = 0
    if strnum.startswith('0X'): # Проверяем на 16-ю систему счисления
        num = int(strnum[2:], 16)

    elif strnum.startswith('0B'): # Проверяем на 2-ю систему счисления
        num = int(strnum[2:], 2)

    else: # Если не то не другое, значит 10-я система счисления
        num = int(strnum)

    return num
#Удаление запятых между символами
def DeleteCommas(elements):
    for i in range(len(elements)):
        if elements[i].endswith(","):
            elements[i] = elements[i][:-1]

    return elements;
# Функция вывода ошибки
def ERROR (error_string):
    ctypes.windll.user32.MessageBoxW(0, error_string, 'Error', 0)
    exit(0)
