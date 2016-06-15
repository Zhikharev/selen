#include "spi.h"

static inline
/*avoid collision  with built-in name */
void memcpy_(volatile void *dest, volatile void *src, size_t n)
{
   volatile char *csrc = (volatile char *)src;
   volatile char *cdest = (volatile char *)dest;

   for (int i=0; i<n; i++)
       cdest[i] = csrc[i];
}

/**
 * read data from flash
 *
 * @param destination - buffer to store received data,
 * @param start_address - start 3-byte address at flash memory
 * @param size - size to read, must be a multiple of 3*4
 */
void flash_read(volatile void *destination,
                uint32_t start_address,
                const size_t size)
{
    volatile SPI* spi = spi_init();
    /*16 byte transaction*/
    spi->CTRL = deposit(spi->CTRL, 0, 7, 128);

    spi->CTRL |= CTR_LSB;

    /*size that received at each transaction*/
    const size_t TRANSACTION_RECEIVED_SIZE = 3*4;

    /*all received data size*/
    size_t received = 0;
    while(received < size) {

        uint32_t address = start_address + received;
        spi_read(spi, address);

        /*copy DATA[0], [1], [2] to destination buffer*/
        memcpy_(destination + received, &spi->DATA[0], TRANSACTION_RECEIVED_SIZE);

        /*Received size*/
        received += TRANSACTION_RECEIVED_SIZE;
    }
}

uint32_t flash_read_word(uint32_t address)
{
    volatile SPI* spi = spi_init();
    spi->CTRL = deposit(spi->CTRL, 0, 7, 32);

    spi->CTRL |= CTR_LSB;

    spi_read(spi, address);

    return spi->DATA[0];
}

int __attribute__((optimize("Os"))) main()
{
    uint32_t size = flash_read_word(0);

    /*RAM*/
    volatile uint8_t* ram = (uint8_t*)RAM_BASE_ADDRESS;

    /*  read size bytes from 0x4*/
    flash_read(ram, 0x4, size);

    /*jump and start execution there*/
    jump_to(ram);

    /*test_done();*/
    return 1;
}
