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
//`include "cpu/sx_1.v"
`include "cpu/sx_2.v"
//`include "cpu/fifo.v"
//`include "cpu/mem_ctr.v"
`include "cpu/mem_block.v"
`include "cpu/cpu_top.v"

`include "memory_commutator/rtl/commutator.v"
`include "memory_commutator/rtl/fifo.v"
`include "memory_commutator/rtl/ram.v"
`include "memory_commutator/rtl/rom.v"
`include "memory_commutator/rtl/wb_comm.v"

`include "io_hub/rtl/decode.v"
`include "io_hub/rtl/io_hub.v"
`include "io_hub/rtl/io_top.v"
`include "io_hub/rtl/state_machine.v"
`include "io_hub/rtl/uart.v"

`include "selen_top.sv"

`include "../verif/system/uart_interface.sv"
`include "../verif/cpu/testbench/wishbone_if.sv"
`include	"../verif/cpu/items/cpu_typedefs.sv"
`include	"../verif/cpu/items/rv32_transaction.sv"
`include "../verif/cpu/monitors/cpu_wbi_monitor.sv"
`include "../verif/cpu/monitors/cpu_wbd_monitor.sv"

`ifndef CLK_HALF_TIME
`define CLK_HALF_TIME 5ns  
`endif

module system_tb_top #(parameter HDR_WIDTH = 2)  ();

	logic clk;
	logic rst;

	uart_if 		 	uart_intf(clk, rst);
	wishbone_if 	cpu_wbi_intf(clk, rst);
	wishbone_if 	cpu_wbd_intf(clk, rst);

	assign cpu_wbi_intf.cyc     = selen_top.cpu_wbi_cyc;
	assign cpu_wbi_intf.stb     = selen_top.cpu_wbi_stb;
	assign cpu_wbi_intf.addr    = selen_top.cpu_wbi_addr;
	assign cpu_wbi_intf.ack     = selen_top.cpu_wbi_ack;
	assign cpu_wbi_intf.data_in = selen_top.cpu_wbi_data;
	assign cpu_wbi_intf.stall   = selen_top.cpu_wbi_stall;
	assign cpu_wbi_intf.we      = 1'b0;

	assign cpu_wbd_intf.stb     = selen_top.cpu_wbd_stb;
	assign cpu_wbd_intf.we      = selen_top.cpu_wbd_we;
	assign cpu_wbd_intf.be      = selen_top.cpu_wbd_be;
	assign cpu_wbd_intf.addr    = selen_top.cpu_wbd_addr;
  assign cpu_wbd_intf.data_out= selen_top.cpu_wbd_data_o;
	assign cpu_wbd_intf.ack     = selen_top.cpu_wbd_ack;
	assign cpu_wbd_intf.data_in = selen_top.cpu_wbd_data_i;

	cpu_wbd_monitor cpu_wbd_mon;
	cpu_wbi_monitor cpu_wbi_mon;

	reg [31:0] prog_mem [1024];
	integer bin_dscr;
	integer r_dscr;

	initial begin
		$display("CLK_HALF_TIME=%0d", `CLK_HALF_TIME);
		clk = 0;
		forever #`CLK_HALF_TIME clk = !clk;
	end

	selen_top selen_top 
	(
		.sys_clk 	(clk),
		.sys_rst 	(rst),
		.uart_rx 	(uart_intf.tx),
		.uart_tx 	(uart_intf.rx)
	);

	task reset();
		rst = 1;
		uart_send_stop_bit();
		repeat(10) @(posedge clk);
		rst = 0;
	endtask

	task build_checkers();
		$display("%0t Building checkers...", $time());
		cpu_wbi_mon = new(cpu_wbi_intf);
		cpu_wbd_mon = new(cpu_wbd_intf);
		fork
			cpu_wbi_mon.run_phase();
			cpu_wbd_mon.run_phase();
		join_none
	endtask

	task automatic drive_bin();
		foreach(prog_mem[k]) begin
			logic [31:0] data = prog_mem[k];
			for(int i = 31; i >= 0; i = i - 8) begin
				logic [7:0] uart_data = data[i -: 8];
				$display("UART TX: data=%0h", uart_data);
				uart_send_start_bit();
				uart_send_data(uart_data);
				uart_send_stop_bit();
			end
		end
	endtask

	task uart_send_start_bit();
		@(posedge uart_intf.clk);
		uart_intf.tx <= 1'b0;
	endtask

	task uart_send_data(bit[7:0] data);
		for(int i = 7; i >= 0; i--) begin
			@(posedge uart_intf.clk);
			uart_intf.tx <= data[i];
		end
	endtask

	task uart_send_stop_bit();
		@(posedge uart_intf.clk);
		uart_intf.tx <= 1'b1;
	endtask

	task wait_for_end();
		#1000ns;
	endtask

	initial begin 
		bin_dscr = $fopen("image.bin", "rb");
		r_dscr   = $fread(prog_mem, bin_dscr);
		foreach(prog_mem[i]) begin
			if($isunknown(prog_mem[i])) break;
			$display("PROG MEM[%0d] %8h", i, prog_mem[i]);
		end
	end

	initial begin
		$display("%0t TEST START", $time());
		build_checkers();
		reset();
		drive_bin();
		wait_for_end();
		$display("%0t TEST FINISHED", $time());
		$finish();
	end



endmodule

`endif
