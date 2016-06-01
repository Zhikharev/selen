
#include <stdint.h>
#include "test_api.h"

void test_done(int reval, const uint32_t test_id) {
	uint32_t* address = TEST_STOP_ADDR;
	*address = test_id;
	*address = reval;
}

int  read_byte(uint32_t base, uint32_t offset, uint8_t* data) {
	uint32_t* address = base + offset;
	*data = (uint8_t)(*address);
	return 1;
}

int  read_word(uint32_t base, uint32_t offset, uint32_t* data) {
	uint32_t* address = base + offset;
   asm volatile("lw %0, %1;" : "=r"(data) , "=o"(address));
	return 1;
}
int  write_byte(uint32_t base, uint32_t offset, uint8_t* data) {
	uint32_t* address = base + offset;
	*address = *data;
	return 1;
}

int  write_word(uint32_t base, uint32_t offset, uint32_t* data) {
	uint32_t* address = base + offset;
	*address = *data;
	return 1;
}

void print_str(const char* sval) 		{}
void print_hex(int hval, int width) {}
void print_bin(int bval, int width) {}
void print_dec(int dval, int width) {}