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

typedef __UINT64_TYPE__ tick_t;

#pragma pack(push, 4)
/*SPI Master core registers*/
typedef volatile struct
{
    uint32_t R[4]; //Data receive registers
    uint32_t T[4]; //Data transmit registers
    uint32_t CTRL; //Control and status register
    uint32_t DIVIDER; //Clock divider register
    uint32_t SS; //Slave select register
} SPI;
#pragma pack(pop)

/*CTRL bits*/
#define CTR_ASS (1 < 13)
#define CTR_IE (1 < 12)
#define CTR_LSB (1 < 11)
#define CTR_TX_NEG (1 < 10)
#define CTR_RX_NEG (1 < 9)
#define CTR_GO_BSY (1 < 8)
#define CTR_TX_NEG (1 < 10)
#define CTR_CHAR_LEN(ctr) extract(ctr, 0, 6) 

/*Memory maped SPI layout base address*/
#define SPI_BASE_ADDRESS 0x2000
/*default clock frequency divider */
#define CLOCK_DIVIDER 1
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

    /*Configure transaction size*/
    spi->CTRL = deposit(spi->CTRL, 0, 6, TRANSACTION_SIZE);
    
    return spi;
}

void spi_transaction(volatile SPI* spi)
{
    /*Select Slave active*/
    spi->SS |= BIT_MASK(SLAVE_ID);
    /*Go*/
    spi->CTRL |= CTR_GO_BSY;
    /*wait till transaction ends*/
    while(spi->CTRL & CTR_GO_BSY);
    
    /*Select Slave inactive*/
    spi->SS &= ~(BIT_MASK(SLAVE_ID));
}

int __attribute__((optimize("Os"))) main()
{
    /*memory base address, from linker script*/
    /*const uint32_t* mem_base = __boot_offset__;*/
    
    volatile SPI* spi = spi_init();

    spi->T[0] = 0xdeadbeaf;
    spi_transaction(spi);
    uint32_t received = spi->R[0];

    /*TODO: NX25Q specific protocol implementation: send commands & addresses -> receive data*/
    /*test_done();*/
    return 1;
}
