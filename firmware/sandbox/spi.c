typedef __SIZE_TYPE__ size_t;
typedef __UINT8_TYPE__ uint8_t;
typedef __UINT32_TYPE__ uint32_t;


/*extract len bits*/
static inline
uint32_t extract(const uint32_t value, const size_t begin,
                 const size_t len)
{
    return (value >> begin) & ((1 << len) - 1);
}

/*put bit field to integer*/
static inline
uint32_t deposit(uint32_t value, int begin, int len,
                 uint32_t fieldval)
{
    uint32_t mask = (~0U >> (32 - len)) << begin;
    return (value & ~mask) | ((fieldval << begin) & mask);
}

#define BIT_MASK(n) ((uint32_t)1 << n)

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

/*Memory maped SPI layout base address*/
#define SPI_BASE_ADDRESS 0x1000
/*default clock frequency divider */
#define CLOCK_DIVIDER 4
/*default slave select bit number*/
#define SLAVE_ID 0
/*default transaction bit size (CTRL.CHAR_LEN)*/
#define TRANSACTION_SIZE 32

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

int __attribute__((optimize("Os"))) main()
{
    /*memory base address, from linker script*/
    /*const uint32_t* mem_base = __boot_offset__;*/

    volatile SPI* spi = spi_init();

    /*инструция READ смотреть 81 страницу в spi_flash_n25q128.pdf*/
    uint32_t operation =  0x3;
    /*3 байтовый адрес (произвольно выбрал)*/
    uint32_t address = 0x000004;

    /*на отрправку идут: 1 байт инструкция + 3 байта адрес*/
    /*на шину данные из регистров передаются [3] [2] [1] [0]*/
    spi->DATA[3] = (operation << 24) | address;

    /*MSB /LSB -? менять тут порядок байт нет я хз,
     * на картинке на 81 странице MSB идет первым
    */
    //spi->CTRL |= CTR_LSB;

    /*размер транзакции надеюсь получать по 16 байт сразу*/
    spi->CTRL = deposit(spi->CTRL, 0, 7, 128);

    spi_transaction(spi);

    volatile uint32_t received = spi->DATA[3];
    received = spi->DATA[2];
    received = spi->DATA[1];
    received = spi->DATA[0];

    /*test_done();*/
    return 1;
}
