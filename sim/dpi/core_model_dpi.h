
#ifdef __cplusplus
extern "C" {
#endif

typedef struct _vcs_dpi_s_model_params  s_model_params;

struct  _vcs_dpi_s_model_params {
  unsigned int    pc_start;
  unsigned int    mem_size;
  /*1 yes, 0 no - allow error messages/debug output*/
  unsigned int    verbose;
  /*1 yes, 0 no - allow resize memory when try to write at invalid address*/
  unsigned int    mem_resize;
  /*1 big endian, 0 little - memory read/write endiannes*/
  unsigned int    endianness;
};

/*return codes*/
#define RC_SUCCESS 1
#define RC_FAIL 0

extern int init(/* INPUT */s_model_params *params);

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

