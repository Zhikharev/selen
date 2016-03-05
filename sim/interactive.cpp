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
                instance->print_help(tokens.str(3));
            }
        },
        {
            cmd_names_t{"quit", "exit", "q"},
            "[\\s]?",
            "exit simulator",
            "dump state to file and exit simulator.",
            []CMD_OPERATION
            {
                instance->exit(0);
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

                instance->load(filename, addr);
            }
        },
        {
            cmd_names_t{"status","st"},
            "[\\s]?",
            "check simulator and program status",
            "print simulator status: steps, programm code, errors, and etc.",
            []CMD_OPERATION
            {
                instance->print_status();
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

                instance->enable_tracing(plug);
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

                instance->touch_pc(arg);
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

                instance->step(steps);
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

                instance->disassemble(num_words, start_addr);
            }
        },
        {
            cmd_names_t{"print","p"},
            "[\\s]+(reg|mem)([\\s]+([\\s\\S]+))*",
            "print register or region of memory",
            "arguments: reg <name>, or mem <address> [format] \n\nprint register or memory,\n"
            "\tif reg name is empty then dump all registers,\n"
            "\t[format] arument valid only for memory, specifies output format: \n"
            "\t\tb/s/w/i- bytes/symbols/words/disasemled instructions,  x/d - hex/dec (valid only for b and w), ",
            []CMD_OPERATION
            {
                std::string type = tokens.str(4);
                std::string arg = tokens.str(6);

                if(type == "reg")
                {
                    instance->print_register(arg);
                    return;
                }

                std::cout << "memory printing not implemented yet";
//                selen::memory_t::memory_dumper dmp;
//                state.mem.dump(std::cout, len ,addr, dmp);
            }
        }
    };

    return map;
}

std::string compose_reg_names_string(const std::string& separator = std::string(", "))
{
    const std::vector<std::string>& names = selen::get_reg_names();
    std::string product;

    selen::reg_id_t id = selen::R_FIRST;
    for (; id < selen::R_LAST - 1; id++)
    {
        product.append(names.at(id));
        product.append(separator);
    }

    //last one without separator
    product.append(names.at(id));
    return product;
}

int Interactive::run()
{
    if(running)
        return EXIT_FAILURE;

    main_cycle();

    return EXIT_SUCCESS;
}

void Interactive::print_help(const std::string command) const
{
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
            std::cout << "\t" << std::setw(fmtwidht) << cmd.print_names()
                      << " - " << cmd.description << std::endl;
            return;
        }

        std::cout << "undefined command: " << command << std::endl;
    }

    std::cout << "Avaible commands:\n";

    for(const Command& token : commands)
    {
        std::cout << "\t" << std::setw(fmtwidht) << token.print_names()
            << " - " << token.brief << std::endl;
    }

    std::cout << "\n\tUse \"help <command>\" to get special command help";
}

void Interactive::print_status() const
{
    std::cout << parent->get_simulator().get_status() << std::endl;
}

void Interactive::print_register(const std::string &name) const
{
    if(name.empty())
    {
        parent->get_simulator().dump_registers(std::cout);
        return;
    }

    const selen::CoreState &state = parent->get_simulator().get_core_state();
    selen::reg_id_t id = selen::name2regid(name);

    if(id == selen::R_LAST)
        std::cout << "there is no register \"" << name << "\"."
                     "\nAvaible registers:\n"
                  << compose_reg_names_string() << std::endl;
    else
        std::cout << selen::regid2name(id) << ": "
                  << std::hex << state.reg.read<selen::word_t>(id)
                  << std::endl;
}

void Interactive::exit(int exit_code)
{
    if(!parent->get_parameters().quiet)
        std::cerr << "exit interactive regime\n";

    running.store(false);
    parent->exit(exit_code);
}

void Interactive::load(std::string filename, size_t addr)
{
    if(filename.empty())
        filename = parent->get_parameters().imagefilename;
    else
    {
        Parameters temp = parent->get_parameters();
        temp.imagefilename = filename;
        parent->set_parameters(temp);
    }

    selen::memory_t image = read_file<selen::memory_t>(filename);
    parent->get_simulator().load(image, true, addr);

    std::cout << "image " << filename << " was loaded to simulator memory at address "
              << std::showbase << std::hex << addr << std::endl;
}

void Interactive::enable_tracing(bool enable)
{
    parent->get_simulator().enable_tracing(enable);
    std::cout << "tracing: " << ((parent->get_simulator().get_config().trace)? "on": "off") << std::endl;
}

void Interactive::disassemble(size_t num_words, size_t start_addr) const
{
    if(!parent->get_parameters().quiet)
        std::cout << "dissasemble " << std::dec << num_words << " words from address "
                  << std::hex << start_addr
                  << std::endl;

    const selen::memory_t& memory = parent->get_simulator().get_memory();

    memory.dump(std::cout, num_words, start_addr, selen::isa::disasembler_dumper());
}

void Interactive::step(size_t steps)
{
    if(!parent->get_parameters().quiet)
        std::cout << "start " << std::dec << steps << " step from "
                  << std::hex << parent->get_simulator().get_program_counter()
                  << std::endl;

    size_t performed = parent->get_simulator().step(steps);

    if(!parent->get_parameters().quiet)
        std::cout << "steps performed " << std::dec << performed << ", current pc "
                << std::hex << parent->get_simulator().get_program_counter()
                << std::endl;
}

void Interactive::touch_pc(const std::string &arg)
{
    if(!arg.empty())
    {
        selen::addr_t pc = std::stoul(arg, 0, 0);
        parent->get_simulator().set_program_counter(pc);
    }

    std::cout << "current pc: " << std::hex << std::showbase
              << parent->get_simulator().get_program_counter() << std::endl;
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
                cmd.operation(this, arguments);
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
        std::cerr << "Simulator at interactive regime\n";

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
