#! /bin/bash
# ---------------------------------------------------------
#
# ---------------------------------------------------------
# FILE NAME      : appennd_size.sh
# PROJECT        : Selen
# AUTHOR         :
# AUTHOR'S EMAIL :
# ---------------------------------------------------------
# DESCRIPTION 	 :
# Script adds size to the binary file
# Usage: sh appennd_size.sh program.bin
# After processing program.bin.output file will be created
# ---------------------------------------------------------


if [ "$#" -ne 1 ]; then
    echo "There are only one argument should be passed: filename"
    exit 1
fi

filename=$1

if [ ! -e "$filename" ]
then
  echo "$filename is a not exist or not the file."
  exit 1
fi

filesize=`wc -c < $filename`
filesize_hex=`printf "%08x\n" $filesize`

echo "file $filename size: $filesize(0x$filesize_hex) bytes"

echo -n $filesize_hex | xxd -r -p > somefile
riscv32-unknown-elf-objcopy -I binary -O binary --reverse-bytes=4 somefile somefile
cat somefile $filename > $filename.output

exit 0