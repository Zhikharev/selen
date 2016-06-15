#ifndef SPI_H
#define SPI_H

#include "utils.h"
#include "memory_map.h"

#pragma pack(push, 4)
/*SPI Master core registers*/
typedef volatile struct
{
    uint32_t DATA[4]; //Data receive registers
    uint32_t CTRL; //Control and status register
    uint32_t DIVIDER; //Clock divider register
    uint32_t SS; //Slave select register
} SPI;
#pragma pack(pop)

/*CTRL bits*/
#define CTR_ASS    BIT_MASK(13)
#define CTR_IE     BIT_MASK(12)
#define CTR_LSB    BIT_MASK(11)
#define CTR_TX_NEG BIT_MASK(10)
#define CTR_RX_NEG BIT_MASK(9)
#define CTR_GO_BSY BIT_MASK(8)
#define CTR_CHAR_LEN(ctr) extract(ctr, 0, 6)

/*n25q128 read instruction code*/
#define SPI_INSTRUCTION_READ 0x3

/*default clock frequency divider */
#define CLOCK_DIVIDER 4
/*default slave select bit number*/
#define SLAVE_ID 0

static
volatile SPI* spi_init()
{
    /*map SPI struct to memory*/
    volatile SPI* spi = (SPI*)SPI_BASE_ADDRESS;
    /*clear all settings*/
    spi->CTRL = 0;

    /*wait till last transaction ends (if exist)*/
    while(spi->CTRL & CTR_GO_BSY);

    /*Auto SS assertion when toggled GO_BSY*/
    /*spi->CTRL |= CTR_ASS;*/

    /*spi->CTRL |= CTR_IE; Interrupts disabled*/

    /*configure clock*/
    spi->DIVIDER = CLOCK_DIVIDER;

    return spi;
}

void spi_transaction(volatile SPI* spi)
{
    /*Select Slave active*/
    spi->SS |= BIT_MASK(SLAVE_ID);
    /*Go*/
    spi->CTRL |= CTR_GO_BSY;

    /*wait till transaction ends*/
    while(spi->CTRL & CTR_GO_BSY)

    /*Select Slave inactive*/
    spi->SS &= ~(BIT_MASK(SLAVE_ID));
}

void spi_read(volatile SPI* spi, uint32_t address)
{
    /* 3 byte address
     * NOTE : n25q128:
     * When the highest address is reached, the address counter rolls over to
        000000h, allowing the read sequence to be continued indefinitely.
    */
    address &= 0xffffff;

    /*
        CTR_LSB bit is set, the LSB is sent first on the line (bit TxL[0]), and the first bit received
        from the line will be put in the LSB position in the Rx register (bit RxL[0]). If this bit
        is cleared, the MSB is transmitted/received first (which bit in TxX/RxX register that is
        depends on the CHAR_LEN field in the CTRL register)
    */
    uint32_t char_len = CTR_CHAR_LEN(spi->CTRL);

    size_t index;
    if(spi->CTRL & CTR_LSB)
    {
        index = 0;
    } else {
        assert(char_len >= 32 && char_len % 32 == 0);
        index = char_len / 32 - 1 ;
    }

    spi->DATA[index] = (SPI_INSTRUCTION_READ << 24) | address;
    spi_transaction(spi);
}

#endif // SPI_H
