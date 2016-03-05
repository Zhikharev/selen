#ifndef APPLICATION_H
#define APPLICATION_H

#include "simulator.h"

class Application;

struct Parameters
{
    Parameters(Application* p) : parent(p)
    {}

    Application* parent;
    selen::Config sim_config;

    std::string imagefilename;

    //dump destination
#define DEFAULT_FINAL_DUMP_DST "fd.txt"
#define DEFAULT_INIT_DUMP_DST "id.txt"
    std::string final_dump = {DEFAULT_FINAL_DUMP_DST};
    std::string init_dump = {DEFAULT_INIT_DUMP_DST};

    enum regime_t
    {
        //from entry point to the end
        R_SIMPLE,
        R_INTERACTIVE
    } regime = {R_SIMPLE};

    bool quiet = {false};
};

std::ostream &operator<<(std::ostream& os, const Parameters& st);

class Application
{
    int const VALID_MIN_ARGC = 1;

public:

    static Application& instance()
    {
        static Application app;

        return app;
    }

    void init(int argc, char *argv[]);
    std::string print_help();
    std::string print_banner();

    void exit(int status);

    selen::Machine& get_simulator()
    {
        return sim;
    }
    const Parameters& get_parameters() const
    {
        return params;
    }
    void set_parameters(const Parameters& new_params)
    {
         params = new_params;
    }

    int run();
    void dump_state_to_file(const std::string& filename);

private:
    Application() : params(this)
    {
    }

protected:
    Application(const Application&) = delete;
    Application& operator=(const Application&) = delete;

    void parse_cl(int argc, char* argv[]);

    //regimes
    void run_simple();
    void run_interactive();

private:
    Parameters params;
    selen::Machine sim;
};

#endif // APPLICATION_H
