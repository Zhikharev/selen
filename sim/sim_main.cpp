#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>

#include "simulator.h"

void print_usage(std::ostream& out)
{
    out <<
        "Usage:\t"  "sim <endianness> <steps> <entrypc> <imagefile>\n"
        "\n"
        "where:\n"
            "\t<endianness> - one of \"LE\" or \"BE\" - word endianness at imagefile\n"
            "\t<steps>      - number of steps\n"
            "\t<entrypc>    - PC start position\n"
            "\t<imagefile>  - binary executable\n"
        "\n"
        "all parameters are strongly required"
        "\nExample: \n ./sim LE 25 0x45c image.bin\n"
        "\n";
}

selen::memory_t read_file(const std::string& filename)
{
    std::ifstream in (filename, std::ios::binary | std::ios::in | std::ios::ate);
    in.exceptions (std::ifstream::failbit | std::ifstream::badbit);

    if (!in.is_open ())
        throw std::runtime_error ("unable open");

    size_t image_size = in.tellg();
    in.seekg(std::ios_base::beg);

    selen::memory_t image (image_size);
    in.read(reinterpret_cast<char*> (image.data ()), image_size);

    std::streamsize chars_readed = in.gcount ();
    if (chars_readed == 0 )
        throw std::runtime_error ("unable read image");

    return image;
}


selen::Config parse_command_line(int argc, char* argv[])
{
    if(argc < 4)
    {
        std::ostringstream out;

        out << "too few arguments: " << argc << std::endl;
        print_usage(out);
        throw std::invalid_argument(out.str());
    }

    selen::Config config;

    std::string endianness(argv[1]);
    if(endianness != "BE" && endianness != "LE")
        throw std::invalid_argument(
                std::string("wrong endianness argument, must be BE or LE, got: ") + endianness);

    config.endianness = (endianness == "BE") ? selen::memory_t::BE : selen::memory_t::LE;

    std::string steps(argv[2]);
    config.steps = std::stoul(steps, 0);

    std::string pcentry(argv[3]);
    config.pc = std::stoul(pcentry, 0);

    config.imagefilename = std::string(argv[4]);

    config.dumpfile = "dump.txt";
    //auto fit if small
    config.mem_size = 10;
    //enable tracing
    config.trace = true;


    //output
    size_t field_width = 20;
    std::cout << std::setw(field_width) << "CONFIG|"
              << std::setw(field_width) << "endianness: "
              << endianness << std::endl;


    std::cout << std::setw(field_width) << "CONFIG|"
              << std::setw(field_width) << "steps: "
              << config.steps << std::endl;


    std::cout << std::setw(field_width) << "CONFIG|"
              << std::setw(field_width) << "PC entry: "
              << config.pc << std::endl;

    std::cout << std::setw(field_width) << "CONFIG|"
              << std::setw(field_width) << "image: "
              << config.imagefilename << std::endl;

    return config;
}

int main(int argc, char* argv[])
try
{
    selen::Config config = parse_command_line(argc, argv);

    selen::Simulator simulator(config);
    
    selen::memory_t image = read_file(config.imagefilename);
    simulator.load(image);

    std::cout << "image " << config.imagefilename << " loaded\n"
              << "initial memory layout:\n\n";
    simulator.dump_memory(std::cout);
    std::cout << std::endl;

    std::cout << "start step..." << std::endl;
    size_t steps_made = simulator.step(config.steps);

    std::cout << "\n\nSUMMARY:\n\nsteps made: " << std::dec << steps_made << std::endl;

    std::ofstream fout(config.dumpfile);
    simulator.dump_registers(fout);
    simulator.dump_memory(fout);
    fout.close();

    std::cout << "State dumped to " << config.dumpfile << std::endl;
}
catch(std::exception& e)
{
    std::cerr << "Error: " << e.what() << std::endl;
    return EXIT_FAILURE;
}
