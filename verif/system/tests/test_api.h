void test_done(int reval, const uint32_t test_id);

int  read_byte(uint32_t base, uint32_t offset, uint8_t* data);
int  read_word(uint32_t base, uint32_t offset, uint32_t* data);
int  write_byte(uint32_t base, uint32_t offset, uint8_t* data);
int  write_word(uint32_t base, uint32_t offset, uint32_t* data);

void print_str(const char* sval);
void print_hex(int hval, int width);
void print_bin(int bval, int width);
void print_dec(int dval, int width);