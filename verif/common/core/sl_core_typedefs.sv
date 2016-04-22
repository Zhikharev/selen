typedef enum bit [2:0] {
    RD    = 3'b000,
    WR    = 3'b001,
    RDNC  = 3'b010,
    WRNC  = 3'b011
} core_cop_t;

typedef bit [2:0] core_size_t;

typedef bit [31:0] core_addr_t;

typedef bit [31:0] core_data_t;

typedef bit [3:0] core_be_t;

typedef enum int {INSTR, DATA} core_port_t;

