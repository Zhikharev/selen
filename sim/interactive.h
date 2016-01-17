#ifndef INTERACTIVE_H
#define INTERACTIVE_H

#include <atomic>
#include <regex>
#include <functional>
#include <list>

#include "application.h"

//Interactive regime

#define DEFAULT_PROMT "isa-sim"

class Interactive;

typedef std::list<std::string> cmd_names_t;
struct Command
{
    //names, aliases
    cmd_names_t names;

    //command regex signature
    std::string arguments;

    //data for help
    std::string brief;

    //data for help <coommand>
    std::string description;

    //command operation
#define CMD_OPERATION (Application* app, Interactive* i, std::smatch tokens)
    std::function<void CMD_OPERATION> operation;

    std::string print_names(const std::string& separator = std::string(", ")) const;
    std::regex make_pattern() const;
};

class Interactive
{
public:
    Interactive(Application *p) : parent(p)
    {}

    Interactive(const Interactive&) = delete;
    Interactive& operator=(const Interactive&) = delete;

    ~Interactive()
    {
        running.store(false);
    }

    int run();

    //print help for "command" or list of avaible commands if "command" empty
    std::string print_help(const std::string command = std::string()) const;

protected:
    void main_cycle();
    bool eval(const std::string &token);

private:
    Application *parent;
    std::atomic<bool> running = {false};
    std::string promt = { "(" DEFAULT_PROMT "): "};
};

#endif // INTERACTIVE_H
