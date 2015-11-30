// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : system_tb_top.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_SYSTEM_TB_TOP
`define INC_SYSTEM_TB_TOP

`include "cpu/alu.v"
`include "cpu/brnch_cnd.v"
`include "cpu/cpu_cntr.v"
`include "cpu/hazard_unit.v"
`include "cpu/reg_decode.v"
`include "cpu/reg_exe.v"
`include "cpu/reg_mem.v"
`include "cpu/reg_write.v"
`include "cpu/register_file.v"
`include "cpu/sx_1.v"
`include "cpu/sx_2.v"
`include "cpu/cpu_top.v"

`include "memory_commutator/rtl/comm.v"
`include "memory_commutator/rtl/commutator.v"
`include "memory_commutator/rtl/fifo.v"
`include "memory_commutator/rtl/generic_dpram.v"
`include "memory_commutator/rtl/ram.v"
`include "memory_commutator/rtl/rom.v"
`include "memory_commutator/rtl/wb_comm.v"

`include "io_hub/rtl/decode.v"
`include "io_hub/rtl/fifo.v"
`include "io_hub/rtl/io_hub.v"
`include "io_hub/rtl/io_top.v"
`include "io_hub/rtl/state_machine.v"
`include "io_hub/rtl/uart.v"

`include "uart_interface.sv"

module #(parameter HDR_WIDTH = 2, parameter  ) system_tb_top ();

	logic clk;
	logic rst;

	uart_if uart_intf;

	reg [31:0] prog_mem [0:31];

	initial begin
		clk = 0;
		forever #10 clk = !clk;
	end

	selen_top selen_top 
	(
		.sys_clk 	(sys_clk),
		.sys_rst 	(sys_rst),
		.uart_rx 	(uart_intf.rx),
		.uart_tx 	(uart_intf.tx)
	);

	task reset();
		rst = 1;
		repeat(10) @(posedge clk);
		rst = 0;
	endtask

	task drive_bin();
		foreach[prog_mem[i]] begin
			logic [31:0] data = prog_mem[i];
			for(int i = 0; i <= 32; i = i + 8) begin
				logic [7:0] uart_data = data[i +: 8];
				uart_send_start_bit();
				uart_send_data(uart_data);
				uart_send_stop_bit();
			end
		end
	endtask

	task wait_for_end();
		#1000ns;
	endtask

	initial readmemh("bin_example.bin", prog_mem);

	initial begin
		$display("%0t TEST START", $time());
		reset();
		drive_bin();
		wait_for_end();
		$display("%0t TEST FINISHED", $time());
		$finish();
	end



endmodule

`endif