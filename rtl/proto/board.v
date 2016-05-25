`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:50 05/24/2016 
// Design Name: 
// Module Name:    board 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module board(
	output 	led,
	input 	button,
	input 	clk,
	input   rst,
	output  lock,
	output  dbg_led
 );

wire 	gpio_pin0_o;
wire 	gpio_pin0_en;
wire 	gpio_pin0_i;

wire 	gpio_pin1_o;
wire 	gpio_pin1_en;
wire 	gpio_pin1_i;

wire cmt_clk;
wire cmt_lock;

wire sync_rst;

assign gpio_pin0_i = button;
assign led = gpio_pin1_en & gpio_pin1_o;
assign lock = cmt_lock;
assign dbg_led = gpio_pin1_en;

cmt cmt (
	.CLK_IN1(clk),
  .CLK_OUT1(cmt_clk),
  .RESET(rst),
  .LOCKED(cmt_lock)
);

reset_sync sync (
	.reset_in 	(rst),
	.clk 				(cmt_clk),
	.enable 		(cmt_lock),
	.reset_out	(rst_sync)
);

selen_top selen_top(
	.clk 	 			  (cmt_clk),
	.rst_n 			  (~rst_sync),
	.gpio_pin0_o  (gpio_pin0_o),
	.gpio_pin0_en (gpio_pin0_en),
	.gpio_pin0_i 	(gpio_pin0_i),
	.gpio_pin1_o 	(gpio_pin1_o),
	.gpio_pin1_en (gpio_pin1_en),
	.gpio_pin1_i  (gpio_pin1_i)
);

endmodule
