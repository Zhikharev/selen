#ifndef DEFINES123456789SELEN
#define DEFINES123456789SELEN
/*
 * Common types
 */
#include <cstdint>

//Bits extraction
//least n bits
#define bit_least(val, n) ((val) & ((1 << (n)) - 1))

//extract sequence, begin inclusive, end exclusive
#define bit_seq(val, begin, end) bit_least((val) >> (begin), ((end) - (begin)))

//disasembler formated output

//mnemonic field widht
#define MF_WIDHT 6
//regname field widht
#define RN_WIDHT 3
//address field widht
#define ADR_WIDHT 12
//instruction field widht
#define INST_WIDHT 12
//

//base field widht for entries at logs
#define FMT_WIDHT 30

namespace selen
{

typedef uint8_t   byte_t;
typedef uint16_t  hword_t;
typedef uint32_t  word_t;

//signed
typedef int8_t   sbyte_t;
typedef int16_t  shword_t;
typedef int32_t  sword_t;

constexpr size_t WORD_SIZE = sizeof(word_t);

//address
typedef uint32_t  addr_t;

} //namespace selen

#endif //DEFINES123456789SELEN
