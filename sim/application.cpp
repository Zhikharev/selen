#include <vector>
#include <string>
#include <functional>
#include <regex>
#include <sstream>
#include <iostream>
#include <algorithm>
#include <atomic>
#include <thread>
#include <fstream>

#include "application.h"
#include "interactive.h"
#include "utils.h"

using namespace std;

//command line option handling

struct CLOption
{
    string name;
    string alias;
    string arguments;
    string description;
#define OPERATION (Parameters& param, smatch tokens)
    function<void OPERATION> operation;
};
typedef vector<CLOption> cloption_map_t;
static const cloption_map_t& get_cloptions();

static const cloption_map_t& get_cloptions()
{
    static cloption_map_t options =
    {
        {
            "endianess",
            "e",
            "le|be|LE|BE",
            "word endianness at imagefile, LE -little endian, BE - big endian",
            []OPERATION
            {
                string endianess = tokens.str(3);
                transform(endianess.begin(), endianess.end(), endianess.begin(), ::tolower);

                if(endianess == "be")
                    param.sim_config.endianness = selen::memory_t::BE;
            }
        },
        {
            "image",
            "img",
            "[\\S]+",
            "path to memory image file",
            []OPERATION
            {
                string filename = tokens.str(3);
                if(filename.empty())
                    throw runtime_error("mising image filename argument");

                param.imagefilename = filename;
            }
        },
        {
            "final-dump",
            "fd",
            "[\\S]*",
            "state will dumped here after execution, default " DEFAULT_FINAL_DUMP_DST,
            []OPERATION
            {
                string filename = tokens.str(3);
                if(filename.empty())
                    throw runtime_error("mising final-dump filename argument");

                param.final_dump = filename;
            }
        },
        {
            "help",
            "h",
            "[\\s]?",
            "show help and exit",
            []OPERATION
            {
                cerr << param.parent->print_help() << endl;
                param.parent->exit(1);
            }
        },
        {
            "program-counter",
            "pc",
            "0[xX][0-9a-fA-F]+",
            "program-counter start value(hex with 0x prefix)",
            []OPERATION
            {
                param.sim_config.pc =  std::stoul(tokens.str(3));
            }
        },
        {
            "adress-space-size",
            "as",
            "[0-9]+",
            "address space byte size (dec)",
            []OPERATION
            {
                param.sim_config.mem_size =  std::stoul(tokens.str(3));
            }
        },
        {
            "steps",
            "s",
            "[0-9]+",
            "number of steps to perform (dec)",
            []OPERATION
            {
                param.sim_config.steps =  std::stoul(tokens.str(3));
            }
        },
        {
            "quiet",
            "q",
            "[\\s]?",
            "be quiet",
            []OPERATION
            {
                param.quiet = true;
            }
        },
        {
            "no-tracing",
            "nt",
            "[\\s]?",
            "disable tracing (tracing is enabled by default)",
            []OPERATION
            {
                param.sim_config.trace = false;
            }
        },
        {
            "interactive",
            "i",
            "[\\s]?",
            "run in interactive regime (simple regime by default)",
            []OPERATION
            {
                param.regime =  Parameters::R_INTERACTIVE;
            }
        }

    };

    return options;
}

Application::Application(int argc, char *argv[]) : params(this)
{
    parse_cl(argc, argv);
    sim.set_config(params.sim_config);
}

string Application::print_help()
{
    static ostringstream out;
    out.str("");

    out << print_banner()
        << "Options:\n";

    const cloption_map_t& options = get_cloptions();
    for (const CLOption& token : options)
        out << setw(fmtwidht) << (string("--") + token.name) << ","
            << setw(5) << (string("-") + token.alias)
            << " - " << token.description << endl;

    return out.str();
}

string Application::print_banner()
{
    return string("Selen isa simulator 2015.");
}

void Application::exit(int status = EXIT_SUCCESS)
{
    return ::exit(status);
}

int Application::run()
{
    if(!params.quiet)
        cout << print_banner() << std::endl
             << "Parameters:\n" << params << std::endl;

    switch(params.regime)
    {
    case Parameters::R_INTERACTIVE:
        run_interactive();
        break;

    case Parameters::R_SIMPLE:
        run_simple();
        break;

    default:
        throw invalid_argument("get invalid regime");
    }

    return sim.get_status().return_code;
}

void Application::dump_state_to_file(const string &filename)
{
    ofstream out(filename);
    sim.dump_registers(out);
    sim.dump_memory(out);
    out.close();

    if(!params.quiet)
        cout << "State dumped to " << params.final_dump << endl;
}

void Application::parse_cl(int argc, char *argv[])
{
    if(argc < VALID_MIN_ARGC)
        throw invalid_argument("too few arguments");

    string line;
    const string separator(" ");
    for (int i = 1; i < argc; i++)
        line.append(separator + string(argv[i]));

    const cloption_map_t& action_map = get_cloptions();

    smatch match;
    ostringstream rgxfmt;

    for(const CLOption& candidate : action_map)
    {
        rgxfmt.str("");
        rgxfmt << "-{1,2}(" << candidate.name << "|" << candidate.alias
               << ")( |=)?(" << candidate.arguments << ")\\b";

        if(regex_search(line, match, regex(rgxfmt.str())))
            candidate.operation(params, match);
    }

}

void Application::run_simple()
{
    if(params.imagefilename.empty())
        throw runtime_error("not specified image file");

    selen::memory_t image = read_file<selen::memory_t>(params.imagefilename);
    sim.load(image);
    if(!params.quiet)
        cout << "Image " << params.imagefilename << " loaded\n";

    dump_state_to_file(params.init_dump);

    if(!params.quiet)
        cout << "Start step..." << endl;
    sim.step(params.sim_config.steps);

    cout << "\n\nSUMMARY:\n\n"
         << sim.get_status() << std::endl;

    dump_state_to_file(params.final_dump);
}

void Application::run_interactive()
{
    Interactive instance(this);

    instance.run();
    return;
}


ostream &operator<<(ostream &os, const Parameters &params)
{
    os << setw(fmtwidht) << "image file: " << ((params.imagefilename.empty()) ?"<not specified>" : params.imagefilename) << std::endl
       << setw(fmtwidht) << "state dump to: " << params.init_dump << std::endl
       << setw(fmtwidht) << "state dump to: " << params.final_dump << std::endl
       << setw(fmtwidht) << "regime: " << ((params.regime == Parameters::R_INTERACTIVE) ? "interactive" : "simple") << std::endl
       << setw(fmtwidht) << "Simulator config: \n" << params.sim_config;

    return os;
}
