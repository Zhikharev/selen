module tb_top ();

	reg clk;
	reg rst;

	reg 													l1i_req_val;
	reg 	[`CORE_ADDR_WIDTH-1:0] 	l1i_req_addr;
	reg                        		l1i_req_ack;
	reg	[`CORE_DATA_WIDTH-1:0] 		l1i_ack_data;

	reg wb_ack;
	reg wb_stb;
	reg [`CORE_DATA_WIDTH-1:0] wb_data;

	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	initial begin
		rst = 1;
		l1i_req_val = 0;
		l1i_req_addr = 0;
		wb_ack = 0;
		wb_data = 0;
		repeat(5) @(posedge clk);
		rst = 0;
	end

	initial begin
		wait(rst == 0);
		repeat(2) begin
			@(posedge clk);
			l1i_req_val = 1;
			l1i_req_addr = 0;
			@(posedge clk);
			wait(l1i_req_ack == 1);
			l1i_req_val = 0;
		end
		#100;
	end

	initial begin
		forever begin
			@(posedge clk);
			if(wb_stb) begin
				wb_ack  <= 1;
				wb_data <= wb_data + 1;
			end
			else wb_ack <= 0;
		end
	end


	l1_dut dut 
	(
		.clk 					(clk),
		.rst_n 				(~rst),
		// L1I interface
		.l1i_req_val 	(l1i_req_val),
		.l1i_req_addr (l1i_req_addr),
		.l1i_req_ack 	(l1i_req_ack),
		.l1i_ack_data (l1i_ack_data),
		// L1D interface
		.l1d_req_val 	(),
		.l1d_req_addr (),
		.l1d_req_cop 	(),
		.l1d_req_wdata(),
		.l1d_req_size (),
		.l1d_req_be 	(),
		.l1d_req_ack 	(),
		.l1d_ack_data (),
		// Wishbone B4 interface
		.wb_clk_i 		(clk),
		.wb_rst_i 		(rst),
		.wb_dat_i 		(wb_data),
		.wb_dat_o 		(),
		.wb_ack_i 		(wb_ack),
		.wb_adr_o 		(),
		.wb_cyc_o 		(),
		.wb_stall_i 	(0),
		.wb_err_i 		(0), 	// not used now
		.wb_lock_o 		(), 	// not used now
		.wb_rty_i 		(0), 	// not used now
		.wb_sel_o 		(),
		.wb_stb_o 		(wb_stb),
		.wb_tga_o 		(), 	// not used now
		.wb_tgc_o 		(), 	// not used now
		.wb_we_o 			()
	);

endmodule