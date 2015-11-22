module cpu (
    input[31:0] instr_data_in,
    input instr_akn_in,
    input instr_stall_in,
    output instr_cyc_out,
    output instr_stb_out,
    ////////////////////
    output data_stb_out,
    output[31:0] data_addr_out,
    output data_we_out,
    output[3:0] data_be_out,
    input data_akn_in,
    output[31:0] data_data_out,
    input[31:0] data_data_in 
);





endmodule cpu
