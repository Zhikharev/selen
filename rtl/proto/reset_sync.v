`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:20:29 04/23/2016 
// Design Name: 
// Module Name:    reset_sync 
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

module reset_sync #(
  parameter INITIALISE = 2'b11
)
(
   input       reset_in,
   input       clk,
   input       enable,
   output      reset_out
);


wire  reset_stage1;
wire  reset_stage2;

  (* ASYNC_REG = "TRUE", RLOC = "X0Y0",  SHREG_EXTRACT = "NO" *)
  FDPE #(
   .INIT (INITIALISE[0])
  ) reset_sync1 (
  .C  (clk), 
  .CE (enable),
  .PRE(reset_in),
  .D  (1'b0),
  .Q  (reset_stage1) 
  );
  
  (* ASYNC_REG = "TRUE", RLOC = "X0Y0",  SHREG_EXTRACT = "NO" *)
  FDPE #(
   .INIT (INITIALISE[1])
  ) reset_sync2 (
  .C  (clk), 
  .CE (enable),
  .PRE(reset_in),
  .D  (reset_stage1),
  .Q  (reset_stage2) 
  );


assign reset_out = reset_stage2;

endmodule
