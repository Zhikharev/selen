import io
import ctypes
InstNotFound = "Instruction NOT FOUND "
RegNotFound = "Register NOT FOUND "
#Перевод числа в бинарную строку со знаковым разрешением
def Addr2Bin(num, length):
    i = bin(num)
    if (num < 0):
        i = i[3:]
    else:
        i = i[2:]

    if len(i) > length - 1: # Проверка на превышение лимита
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
#Функция вывода в бинарный файл
def WriteBinary(ofile, data):
    cur = 0
    while cur < len(data):
        c = int(data[cur:cur+8], 2)
        file.write(bytes(chr(c), 'iso8859-1'))
        cur += 8
#Функция разделения файла по директивам
def SplitToDierctives(ofile):
    directs = {};
    curr_d = "";
    for line in ofile:
        line = line.strip() + '\n'
        line = line.upper();
        if line.startswith('#') :
            continue;

        if '#' in line: # Удаление комментария в строке
            line = line[:line.find('#')] + '\n'
            line = line.strip() + '\n'

        if line.startswith('.'): # Нахождение директив
            # Обработка .code и .data
            if line.startswith('.CODE'):
                curr_d = ".CODE"
                if ".CODE" not in directs:
                    directs[".CODE"] = '';

            if line.startswith('.DATA'):
                curr_d = ".DATA"
                if ".DATA" not in directs:
                    directs[".DATA"] = '';

        else:
            if curr_d != '':
                if len(line) > 1:
                    directs[curr_d] += line

            elif len(line) > 1:
                curr_d = '.CODE'
                directs[curr_d] = line

    return directs;
#Функция для получения меток и удаления их из кода
def GetLabels(code):
    ncode = [];
    labels = {};
    addr = 0;
    for line in code:
        if ":" in line:
            line_elements = line.split(":")
            labels[line_elements[0]] = addr;
            if len(line_elements[1]) > 3:
                ncode.append(line_elements[1].strip())

        else:
            ncode.append(line)

        addr += 4;

    return [ncode, labels]

#Функция для обработки директивы .DATA
def ParseData(data):
    keys = {}
    for line in data:
        line_elements = line.split(" ")
        if len(line_elements) == 2:
            data_num = Str2Num(line_elements[1])
            keys[line_elements[0]] = data_num

        else:
            ERROR("ERROR while DATA parsing in line: " + line);

    return keys
