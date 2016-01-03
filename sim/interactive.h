#ifndef INTERACTIVE_H
#define INTERACTIVE_H

#include <atomic>
#include <regex>
#include <functional>

#include "application.h"

//Interactive regime

#define DEFAULT_PROMT "isa-sim"

class Interactive;
struct Command
{
    //command signature
    std::regex pattern;

    //help coommand use this information
    std::string description;

    //command operation
#define CMD_OPERATION (Application* app, Interactive* i, std::smatch tokens)
    std::function<void CMD_OPERATION> operation;
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
    std::string print_help() const;

protected:
    void main_cycle();
    bool eval(const std::string &token);

private:
    Application *parent;
    std::atomic<bool> running = {false};
    std::string promt = { "(" DEFAULT_PROMT "): "};
};

#endif // INTERACTIVE_H
