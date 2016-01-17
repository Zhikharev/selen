#ifndef TERMINAL_H
#define TERMINAL_H

#include <string>

//terminal handling functions

//now based on linenoise library,
//initial version was based on readline library and i dont like it.

namespace terminal
{

//command line library: https://github.com/antirez/linenoise
#include "linenoise/linenoise.h"
#define COMMAND_HISTORY_FILE "history.txt"


void init()
{
    linenoiseHistoryLoad(COMMAND_HISTORY_FILE);
    linenoiseSetMultiLine(1);
}

std::string readline(const std::string& promt)
{
    static std::string last_valid_command;

    char *line = linenoise(promt.c_str());

    std::string token(line);
    //empty line (enter was pressed ) perform last non empty command
    if(!token.empty())
    {
        linenoiseHistoryAdd(line);
        linenoiseHistorySave(COMMAND_HISTORY_FILE);
        last_valid_command = token;
    }
    else
        token = last_valid_command;


    free(line);

    return token;
}

//void disable_raw_mode(int fd)
//{
//    return disableRawMode(fd);
//}

//int enable_raw_mode(int fd)
//{
//    return enableRawMode(fd);
//}

//int is_raw_mode()
//{
//    return isRawModeEnabled();
//}


} // end terminal namespace


#endif // TERMINAL_H
