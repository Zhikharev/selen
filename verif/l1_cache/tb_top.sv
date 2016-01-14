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
	reg [`CORE_ADDR_WIDTH-1:0] wb_adr;

	semaphore sem;
	int active_req;

	initial begin
		clk <= 0;
		sem = new(1);
		forever #10 clk <= ~clk;
	end

	initial begin
		rst <= 1;
		l1i_req_val <= 0;
		l1i_req_addr <= 0;
		wb_ack <= 0;
		wb_data <= 0;
		repeat(5) @(posedge clk);
		rst <= 0;
	end

	initial begin
		wait(rst == 0);
		repeat(2) begin
			@(posedge clk);
			l1i_req_val <= 1;
			l1i_req_addr <= 0;
			@(posedge clk);
			$display("%0t REQ ADDR=%0h", $time(), l1i_req_addr);
			wait(l1i_req_ack == 1);
			$display("%0t ACK DATA=%0h", $time(), l1i_ack_data);
			l1i_req_val <= 0;
		end
		@(posedge clk);
		l1i_req_val <= 1;
		l1i_req_addr <= 75;
		@(posedge clk);
		$display("%0t REQ ADDR=%0h", $time(), l1i_req_addr);
		wait(l1i_req_ack == 1);
		$display("%0t ACK DATA=%0h", $time(), l1i_ack_data);
		l1i_req_val <= 0;

		#1000;
		$finish();
	end

	initial begin
		int delay;
		forever begin
			@(posedge clk);
			if(wb_stb) begin
				$display("%0t WB REQ ADDR=%0d", $time(), wb_adr);
				while(!sem.try_get());
				active_req++;
				sem.put();
			end
		end
	end

	initial begin
		int delay;
		forever begin
			@(posedge clk);
			if(active_req > 0) begin
				std::randomize(delay) with {delay inside {[0:5]};};
				repeat(delay) begin
					wb_ack <= 0;
					@(posedge clk);
				end
				wb_ack  <= 1;
				wb_data <= wb_data + 1;
				while(!sem.try_get());
				active_req--;
				sem.put();
				$display("%0t WB ACK DATA=%0h", $time(), wb_data);
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
		.wb_adr_o 		(wb_adr),
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