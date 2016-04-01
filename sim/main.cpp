#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>
#include <csignal>

#include "application.h"

std::string static print_usage()
{
    return std::string("Usage:\n type ./sim --help or ./sim -h for help");
}

void INT_handler(int /* signum */)
{
    std::cerr << "SIG INT" << std::endl;

    Application::instance().exit(EXIT_FAILURE);
}

int main(int argc, char* argv[])
try
{
    signal(SIGINT, INT_handler);

    Application::instance().init(argc, argv);
    Application::instance().run();

    return EXIT_SUCCESS;
}
catch(std::exception& e)
{
    std::cerr << "Error: " << e.what() << std::endl
              << print_usage() <<std::endl;
    return EXIT_FAILURE;
}
