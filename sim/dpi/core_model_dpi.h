
#ifdef __cplusplus
extern "C" {
#endif

typedef struct _vcs_dpi_s_model_params  s_model_params;

struct  _vcs_dpi_s_model_params
{
  unsigned int    pc_start;
  unsigned int    mem_size;

  /*1 yes, 0 no - allow resize memory when try to write at invalid address*/
  unsigned int    mem_resize;
  /*1 big endian, 0 little - memory read/write endiannes*/
  unsigned int    endianness;

  /* next two flags can be enabled both together at the same time*/

  /* 1 enable, 0 disable trace output to console*/
  unsigned int    trace_console;

  /* 1 enable, 0 - disable trace output to file*/
  unsigned int    trace_file;

  /*if epmty trace file will be "Trace.txt
  const char*     trace_file_name;*/

  /*console output:
   * 0 - no output (trace_console flag not involved)
   * 1 - output errors
   * 2 - level 1 + dpi function calls with arguments values
   * 3 - level 2 + internal model debug output
  */
  unsigned int    verbosity_level;
};

/*return codes*/
#define RC_SUCCESS 1
#define RC_FAIL 0

extern int init(/* INPUT */s_model_params *params);

/*dump current model state to file*/
extern int dump_state(const char* filename);

extern int get_mem(/* INPUT */unsigned int addr, /* OUTPUT */unsigned int *data);
extern int set_mem(/* INPUT */unsigned int addr, /* INPUT */unsigned int data);

extern int get_reg(/* INPUT */int reg_id, /* OUTPUT */unsigned int *data);
extern int set_reg(/* INPUT */int reg_id, /* INPUT */unsigned int data);

extern int get_pc(/* OUTPUT */unsigned int *data);
extern int set_pc(/* INPUT */unsigned int data);

extern int step();

#ifdef __cplusplus
} /* extern "C" */
#endif

