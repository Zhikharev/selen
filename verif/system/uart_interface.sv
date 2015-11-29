// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : uart_interfce.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_UART_INTERFCE
`define INC_UART_INTERFCE

interface uart_if(input logic clk, input logic rst);
	logic tx;
	logic rx;
endinterface : uart_if
`endif