#include <functional>
#include <regex>
#include <vector>

#include <string.h>

#include "terminal.h"
#include "interactive.h"
#include "utils.h"

typedef std::vector<Command> CommandMap;

void test(std::smatch tokens)
{
    std::cout << "not implemented" << std::endl;
    for (size_t i = 0; i < tokens.size(); i++)
        std::cout << std::dec << i << " : " << tokens.str(i) << std::endl;
}

static const CommandMap& get_commands_map()
{
    static CommandMap map =
    {
        {
            cmd_names_t{"help", "h"},
            "([\\S]+)?\\b",
            "print help.",
            "print help for specific command or list of avaible commands.",
            []CMD_OPERATION
            {
                std::cout << i->print_help(tokens.str(3)) << std::endl;
            }
        },
        {
            cmd_names_t{"quit", "exit", "q"},
            "[\\s]?",
            "exit simulator",
            "dump state to file and exit simulator.",
            []CMD_OPERATION
            {
                app->exit(0);
            }
        },
        {
            cmd_names_t{"load","l"},
            "([\\S]+)?[\\s]*(0?[xX]?[0-9a-fA-F]+)?",
            "load image to memory",
            "arguments: [filename] [address]. Load image from \"filename\"(may be omitted if was specified by command line) to memory at address (default 0).",
            []CMD_OPERATION
            {
                std::string filename = tokens.str(4);
                std::string s_addr = tokens.str(5);

                selen::addr_t addr = (s_addr.empty()) ? 0 : std::stoul(s_addr, 0, 0);

                if(filename.empty())
                    filename = app->get_parameters().imagefilename;
                else
                {
                    Parameters temp = app->get_parameters();
                    temp.imagefilename = filename;
                    app->set_parameters(temp);
                }

                selen::memory_t image = read_file<selen::memory_t>(filename);
                app->get_simulator().load(image, true, addr);

                std::cout << "image " << filename << " was loaded to simulator memory at address "
                          << std::showbase << std::hex << addr << std::endl;
            }
        },
        {
            cmd_names_t{"status","st"},
            "[\\s]?",
            "check simulator and program status",
            "print simulator status: steps, programm code, errors, and etc.",
            []CMD_OPERATION
            {
                std::cout << app->get_simulator().get_status() << std::endl;
            }
        },
        {
            cmd_names_t{"tracing","tr"},
            "(on|off|yes|no)?",
            "tracing settings",
            "arguments:  <none>, [on, off, yes, no] - turn on/off step tracing (to std::cout). By default tracing is on.",
            []CMD_OPERATION
            {
                std::string arg = tokens.str(3);
                std::transform(arg.begin(), arg.end(), arg.begin(), ::tolower);
                bool plug = !(arg == "off" || arg == "no");
                app->get_simulator().enable_tracing(plug);

                std::cout << "tracing: " << ((app->get_simulator().get_config().trace)? "on": "off") << std::endl;
            }
        },
        {
            cmd_names_t{"program-counter","pc"},
            "(0?[xX]?[0-9a-fA-F]+)*",
            "set/get program-counter",
            "arguments:  <none>, [address] - get program-counter if there is no address argument, set if address exists",
            []CMD_OPERATION
            {
                std::string arg = tokens.str(4);

                if(!arg.empty())
                {
                    selen::addr_t pc = std::stoul(arg, 0, 0);
                    app->get_simulator().set_program_counter(pc);
                }

                std::cout << "current pc: " << std::hex << std::showbase
                          << app->get_simulator().get_program_counter() << std::endl;
            }
        },
        {
            cmd_names_t{"step","s"},
            "([0-9]+)*",
            "make steps at simulator",
            "arguments: <none>, [num]. Try to make num (1 if there is no arguments) steps at simulator",
            []CMD_OPERATION
            {
                std::string arg = tokens.str(3);

                size_t steps = (arg.empty()) ? 1: std::stoul(arg, 0, 0);

                if(!app->get_parameters().quiet)
                    std::cout << "start " << std::dec << steps << " step from "
                              << std::hex << app->get_simulator().get_program_counter()
                              << std::endl;

                size_t performed = app->get_simulator().step(steps);

                if(!app->get_parameters().quiet)
                    std::cout << "steps performed " << std::dec << performed << ", current pc "
                            << std::hex << app->get_simulator().get_program_counter()
                            << std::endl;
            }
        },
        {
            cmd_names_t{"disas","d"},
            "(0?[xX]?[0-9a-fA-F]+)+([\\s]+([0-9]+))*",
            "disassemle",
            "arguments: <address> [num]. Disassemle num words(default 10) from address at memory",
            []CMD_OPERATION
            {
                std::string saddr = tokens.str(4);
                std::string snum_words = tokens.str(6);

                size_t num_words = (snum_words.empty()) ? 10 : std::stoul(snum_words, 0, 0);
                size_t start_addr = std::stoul(saddr, 0, 0);

                if(!app->get_parameters().quiet)
                    std::cout << "dissasemble " << std::dec << num_words << " words from address "
                            << std::hex << start_addr
                            << std::endl;

                const selen::memory_t& memory = app->get_simulator().get_state().mem;

                memory.dump(std::cout, num_words, start_addr, selen::isa::disasembler_dumper());
            }
        },
        {
            cmd_names_t{"print","p"},
            "[\\s]+(reg|mem)[\\s]+([\\s\\S]+)*",
            "print register or region of memory",
            "arguments: reg <name>, or mem <address> [format]- print register or memory, [format] valid only for memory, specifies output format: b/s/w/i- bytes/symbols/words/disasemled instructions,  x/d - hex/dec (valid only for b and w), ",
            []CMD_OPERATION
            {
                test(tokens);
//                std::string saddr = tokens.str(2);
//                std::string snum_words = tokens.str(4);

//                size_t num_words = (snum_words.empty()) ? 10 : std::stoul(snum_words, 0, 0);
//                size_t start_addr = std::stoul(saddr, 0, 0);

//                if(!app->get_parameters().quiet)
//                    std::cout << "dissasemble " << std::dec << num_words << " words from address "
//                            << std::hex << start_addr
//                            << std::endl;

//                const selen::memory_t& memory = app->get_simulator().get_state().mem;

//                memory.dump(std::cout, num_words, start_addr, selen::isa::disasembler_dumper());
            }
        }
    };

    return map;
}

int Interactive::run()
{
    if(running)
        return EXIT_FAILURE;

    main_cycle();

    return EXIT_SUCCESS;
}

std::string Interactive::print_help(const std::string command) const
{
    static std::ostringstream out;
    out.str("");

    const CommandMap& commands = get_commands_map();

    if(!command.empty())
    {
        Command cmd;
        bool cmd_found = false;

        for(const Command& token : commands)
        {
            for (const auto& name : token.names)
                if(name == command)
                {
                    cmd = token;
                    cmd_found = true;
                    break;
                }

            if(cmd_found)
                break;
        }

        if(cmd_found)
        {
            out << "\t" << std::setw(fmtwidht) << cmd.print_names()
                << " - " << cmd.description << std::endl;
            return out.str();
        }

        out << "undefined command: " << command << std::endl;
    }

    out << "Avaible commands:\n";

    for(const Command& token : commands)
    {
        out << "\t" << std::setw(fmtwidht) << token.print_names()
            << " - " << token.brief << std::endl;
    }

    out << "\n\tUse \"help <command>\" to get special command help";

    return out.str();
}

bool Interactive::eval(const std::string &token)
{
    static const CommandMap& commands = get_commands_map();
    std::smatch arguments;

    for (const Command& cmd : commands)
    {
        if(std::regex_search(token, arguments, cmd.make_pattern()))
        {
            try
            {
                cmd.operation(parent, this, arguments);
            }
            catch(std::exception& e)
            {
                std::cerr << "command \"" << token << "\" error: " << e.what() << std::endl;
            }

            return true;
        }
    }

    return false;
}

void Interactive::main_cycle()
{
    if(!parent->get_parameters().quiet)
        std::cerr << "Simulator at unteractive regime\n";

    terminal::init();

    running.store(true);
    while(running)
    {
        std::string token = terminal::readline(promt);

        if(!eval(token))
            std::cerr << "unknown command: " << token << std::endl;
    }

    running.store(false);
}


std::string Command::print_names(const std::string &separator) const
{
    static const std::string end("");

    std::string product;
    size_t counter = 0;
    const size_t last_dot_pos = names.size() - 1;
    for (const auto& name : names)
    {
        product.append(name);
        product.append(((counter++ != last_dot_pos) ? separator : end));
    }

    return product;
}

std::regex Command::make_pattern() const
{
    static std::ostringstream rgxfmt;
    static const std::string separator("|");
    rgxfmt.str("");

    rgxfmt << "\\b(" << print_names(separator) << ")"
              "[\\s]*(=)?[\\s]*"
              "(" << arguments << ")\\b";

    return std::regex(rgxfmt.str(), std::regex::icase);
}
