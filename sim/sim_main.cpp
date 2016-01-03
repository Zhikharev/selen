#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>

#include "application.h"

std::string static print_usage()
{
    return std::string("Usage:\n type ./sim --help or ./sim -h for help");
}

int main(int argc, char* argv[])
try
{
    Application app(argc, argv);
    app.run();
    return EXIT_SUCCESS;
}
catch(std::exception& e)
{
    std::cerr << "Error: " << e.what() << std::endl
              << print_usage() <<std::endl;
    return EXIT_FAILURE;
}
