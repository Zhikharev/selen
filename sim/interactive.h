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
#define CMD_OPERATION (Interactive* instance, std::smatch tokens)
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

    //interactive command functions
public:
    void print_help(const std::string command = std::string()) const;
    void print_status() const;
    void print_register(const std::string& name) const;
    void exit(int exit_code);
    void load(std::string filename, size_t addr);
    void enable_tracing(bool enable);
    void disassemble(size_t num_words, size_t start_addr) const;
    void step(size_t steps);
    //special functions for pc command
    void touch_pc(const std::string& arg);

protected:
    void main_cycle();
    bool eval(const std::string &token);

private:
    Application *parent;
    std::atomic<bool> running = {false};
    std::string promt = { "(" DEFAULT_PROMT "): "};
};

#endif // INTERACTIVE_H
