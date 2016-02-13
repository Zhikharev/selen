typedef struct _vcs_dpi_s_model_params  s_model_params;

struct  _vcs_dpi_s_model_params {
  unsigned int    pc_start;
};

extern int init(/* INPUT */s_model_params *params);

// Использование функции execute_instr может скрыть некоторые ошибки в
// ядре. Необходимо класть инструкцию в память, по адресу пришедшему
// от ядра (знаечение rtl pc) и вызывать функцию step модели. Тем
// самым произойдёт проверка, что программные счётчики модели и rtl
// совпадают

// extern int execute_instr(/* INPUT */unsigned int instr);

 extern int mem_set(/* INPUT */unsigned int addr, /* INPUT */unsigned int data);

 extern int mem_get(/* INPUT */unsigned int addr, /* OUTPUT */unsigned int *data);

 extern int reg_get(/* INPUT */int reg_id, /* OUTPUT */unsigned int *data);

 extern int step();


