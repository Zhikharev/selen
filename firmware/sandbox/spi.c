#include "spi.h"

uint32_t flash_read_word(uint32_t address)
{
    volatile SPI* spi = spi_init();

    // TODO: чтобы прочитать слово данных, нужно
    // передать команду+адрес 32 бита, а следующие
    // 32 бита, от флешки придут данные, поэтому
    // размер транзакции 64

    spi->CTRL = deposit(spi->CTRL, 0, 7, 64);

    // TODO: если используем LSB, то в регистре команду
    // нужно записывать не 0000 0011, а 1100 0000
    // spi->CTRL |= CTR_LSB;

    spi_read(spi, address);

    return spi->DATA[0];
}

int __attribute__((optimize("Os"))) main()
{
    const uint32_t size = flash_read_word(0);

    /*RAM*/
    volatile uint32_t* ram = (uint32_t*)RAM_BASE_ADDRESS;

    /*  read size bytes from DATA_OFFSET*/
    size_t DATA_OFFSET = 0x4;
    size_t received = 0;
    while(received < size)
    {
        *(ram++) = flash_read_word(DATA_OFFSET + received);
        received += 4;
    }

    /*jump and start execution there*/
    jump_to(ram);

    /*test_done();*/
    return 1;
}
