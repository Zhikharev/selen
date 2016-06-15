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

/*RAM start address*/
#define RAM_BASE_ADDRESS  0x100000


/*Memory maped SPI layout base address*/
#define SPI_BASE_ADDRESS 0x1000
/*default clock frequency divider */
#define CLOCK_DIVIDER 4
/*default slave select bit number*/
#define SLAVE_ID 0
/*default transaction bit size (CTRL.CHAR_LEN)*/
#define TRANSACTION_SIZE 32
/*n25q128 read instruction code*/
#define SPI_INSTRUCTION_READ 0x3

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

static inline
void memcpy_my(volatile void *dest, volatile void *src, size_t n)
{
   // Typecast src and dest addresses to (char *)
   volatile char *csrc = (volatile char *)src;
   volatile char *cdest = (volatile char *)dest;

   // Copy
   for (int i=0; i<n; i++)
       cdest[i] = csrc[i];
}

/**
 * load data from flash
 *
 * @param destination - buffer to store received data,
 * @param start_address - start 3-byte address at flash memory
 * @param size - size to read, must be a multiple of 3*4
 */
void read_flash(volatile void *destination,
                uint32_t start_address,
                const size_t size)
{
    volatile SPI* spi = spi_init();
    /*16 byte transaction*/
    spi->CTRL = deposit(spi->CTRL, 0, 7, 128);

    /*size that received at each transaction*/
    const size_t TRANSACTION_RECEIVED_SIZE = 3*4;

    /*all received data size*/
    size_t received = 0;
    while(received < size) {
        /* escape 3 byte address
         *
         * NOTE : n25q128:
         * When the highest address is reached, the address counter rolls over to
            000000h, allowing the read sequence to be continued indefinitely.
        */
        uint32_t address = (start_address + received) & 0xffffff;

        /*Make command*/
        spi->DATA[3] = (SPI_INSTRUCTION_READ << 24) | address;

        spi_transaction(spi);

        /*copy DATA[0], [1], [2] to destination buffer*/
        memcpy_my(destination + received, &spi->DATA[0], TRANSACTION_RECEIVED_SIZE);

        /*Received size*/
        received += TRANSACTION_RECEIVED_SIZE;
    }

}

static
void jump_to(volatile void* label)
{
    asm("jalr x0, %0\n"
        "nop\n"
        "nop\n"
        "nop\n"
        : : "r" (label) );
}

int __attribute__((optimize("Os"))) main()
{
    uint32_t buffer[4] = {0};

    read_flash(buffer, 0x0, 4);
    uint32_t size = buffer[0];

    /*RAM*/
    volatile uint8_t* ram = (uint8_t*)RAM_BASE_ADDRESS;

    read_flash(ram, 0x4, size);

    /*jump and start execution there*/
    jump_to(ram);

    /*test_done();*/
    return 1;
}
