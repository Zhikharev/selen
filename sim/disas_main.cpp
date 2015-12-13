#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <iomanip>
#include <cmath>

#include "isa/definitions.h"

using namespace selen;

void print_usage()
{
    std::cerr <<
                 "Usage:\t"  "disasm <endianness>  <imagefile>\n"
                 "\n"
                 "where:\n"
                 "\t<endianness> - one of \"LE\" or \"BE\" - word endianness at imagefile\n"
                 "\t<imagefile>  - binary executable\n"
                 "\n"
                 "all parameters are strongly required"
                 "\nExample: \n ./disasm LE image.bin\n"
                 "\n";
}

memory_t read_file(const std::string& filename)
{
    std::ifstream in (filename, std::ios::binary | std::ios::in | std::ios::ate);
    in.exceptions (std::ifstream::failbit | std::ifstream::badbit);

    if (!in.is_open ())
        throw std::runtime_error ("unable open");

    size_t image_size = in.tellg();
    in.seekg(std::ios_base::beg);

    memory_t image (image_size);
    in.read(reinterpret_cast<char*> (image.data ()), image_size);

    std::streamsize chars_readed = in.gcount ();
    if (chars_readed == 0 )
        throw std::runtime_error ("unable read image");

    return image;
}

int main(int argc, char* argv[])
try
{
    if(argc < 3)
    {
        std::cerr << "too few arguments\n";
        print_usage();
        return EXIT_FAILURE;
    }

    std::string endianness(argv[1]);
    if(endianness != "BE" && endianness != "LE")
        throw std::invalid_argument(
                std::string("wrong endianness argument, must be BE or LE, got: ") + endianness);


    std::string filename(argv[2]);
    memory_t image = read_file(filename);

    image.set_endian((endianness == "BE") ?
                         selen::memory_t::BE : selen::memory_t::LE);

    std::size_t mem_size =  image.size ();

    std::cout << "image " << filename
              << " size " << std::dec << mem_size << " b\n"
              << "endianness: " << ((image.is_little_endian())? "LE" : "BE" )
              << std::endl;

    std::cout << std::showbase;

    size_t avaib_size = std::floor(mem_size /WORD_SIZE) * WORD_SIZE;

    std::string separator("\t");
    for (std::size_t i = 0; i < avaib_size; i = i + WORD_SIZE)
    {
        instruction_t instr = image.read<word_t>(i);

        std::cout << std::setw(10) << std::hex  << i
                  << separator
                  << std::setw(10) << instr
                  << separator
                  << isa::disassemble(instr)
                  << std::endl;
    }
}
catch(std::exception& e)
{
    std::cerr << "Error: " << e.what() << std::endl;
    return EXIT_FAILURE;
}
