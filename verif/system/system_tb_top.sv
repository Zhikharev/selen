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