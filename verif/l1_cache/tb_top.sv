module tb_top ();

	reg clk;
	reg rst;

	reg 												l1i_req_val;
	reg [`CORE_ADDR_WIDTH-1:0] 	 l1i_req_addr;
	reg                        	l1i_req_ack;
	reg	[`CORE_DATA_WIDTH-1:0] 	l1i_ack_data;

	reg 												l1d_req_val;
	reg [`CORE_ADDR_WIDTH-1:0] 	l1d_req_addr;
	reg [`CORE_COP_WIDTH-1:0]   l1d_req_cop;
	reg [`CORE_DATA_WIDTH-1:0] 	l1d_req_wdata;
	reg [`CORE_SIZE_WIDTH-1:0]  l1d_req_size;
	reg [`CORE_BE_WIDTH-1:0]    l1d_req_be;
	reg                        	l1d_req_ack;
	reg	[`CORE_DATA_WIDTH-1:0] 	l1d_ack_data;

	reg wb_ack;
	reg wb_stb;
	reg [`CORE_DATA_WIDTH-1:0] wb_data;
	reg [`CORE_ADDR_WIDTH-1:0] wb_adr;

	semaphore sem;
	int active_req;

	task automatic l1i_read (
		input [`CORE_TAG_WIDTH-1:0] tag, 
		input [`CORE_IDX_WIDTH-1:0] idx, 
		output [`CORE_DATA_WIDTH-1:0] data
	);

		// Its hard to check pipeline mode here
		@(posedge clk);

		$display("L1I READ tag=%0h idx=%0h (%0t)", tag, idx, $time());
		l1i_req_val  <= 1'b1;
		l1i_req_addr <= {tag, idx, {`CORE_OFFSET_WIDTH{1'b0}}};
    while(l1i_req_ack !== 1'b1) begin
      @(posedge clk)
      if(l1i_req_ack) data = l1i_ack_data;
    end
    l1i_req_val <= 1'b0;
    #0;
 		$display("L1I ACK DATA=%0h (%0t)", data, $time());
	endtask

	task automatic l1d_read (
		input [`CORE_TAG_WIDTH-1:0] 	tag, 
		input [`CORE_IDX_WIDTH-1:0] 	idx, 
		input [`CORE_SIZE_WIDTH-1:0]  size,
		output [`CORE_DATA_WIDTH-1:0] data
	);

		// Its hard to check pipeline mode here
		@(posedge clk);

		$display("L1D RD size=%0d tag=%0h idx=%0h (%0t)", size, tag, idx, $time());
		l1d_req_val  <= 1'b1;
		l1d_req_addr <= {tag, idx, {`CORE_OFFSET_WIDTH{1'b0}}};
		l1d_req_size <= size;
		l1d_req_cop  <= `CORE_REQ_RD;
    while(l1d_req_ack !== 1'b1) begin
      @(posedge clk)
      if(l1d_req_ack) data = l1d_ack_data;
    end
    l1d_req_val <= 1'b0;
    #0;
 		$display("L1D ACK DATA=%0h (%0t)", data, $time());
	endtask

	task automatic l1d_nc_read (
		input [`CORE_TAG_WIDTH-1:0]   tag, 
		input [`CORE_IDX_WIDTH-1:0]   idx, 
		input [`CORE_SIZE_WIDTH-1:0]  size,
		output [`CORE_DATA_WIDTH-1:0] data
	);

		// Its hard to check pipeline mode here
		@(posedge clk);

		$display("L1D RDNC size=%0d tag=%0h idx=%0h (%0t)", size, tag, idx, $time());
		l1d_req_val  <= 1'b1;
		l1d_req_addr <= {tag, idx, {`CORE_OFFSET_WIDTH{1'b0}}};
		l1d_req_size <= size;
		l1d_req_cop  <= `CORE_REQ_RDNC;
    while(l1d_req_ack !== 1'b1) begin
      @(posedge clk)
      if(l1d_req_ack) data = l1d_ack_data;
    end
    l1d_req_val <= 1'b0;
    #0;
 		$display("L1D ACK DATA=%0h (%0t)", data, $time());
	endtask

	task automatic l1d_write (
		input [`CORE_TAG_WIDTH-1:0]  tag, 
		input [`CORE_IDX_WIDTH-1:0]  idx, 
		input [`CORE_SIZE_WIDTH-1:0] size,
		input [`CORE_DATA_WIDTH-1:0] data
	);

		// Its hard to check pipeline mode here
		@(posedge clk);

		l1d_req_val  <= 1'b1;
		l1d_req_addr <= {tag, idx, {`CORE_OFFSET_WIDTH{1'b0}}};
		l1d_req_size <= size;
		l1d_req_cop  <= `CORE_REQ_WR;
		l1d_req_wdata <= data;
    while(l1d_req_ack !== 1'b1) begin
      @(posedge clk)
      if(l1d_req_ack) data = l1d_ack_data;
    end
    l1d_req_val <= 1'b0;
 		$display("L1D WR size=%0d tag=%0h idx=%0h (%0t)", size, tag, idx, $time());
	endtask

	task automatic l1d_nc_write (
		input [`CORE_TAG_WIDTH-1:0]  tag, 
		input [`CORE_IDX_WIDTH-1:0]  idx, 
		input [`CORE_SIZE_WIDTH-1:0] size,
		input [`CORE_DATA_WIDTH-1:0] data
	);

		// Its hard to check pipeline mode here
		@(posedge clk);

		l1d_req_val  <= 1'b1;
		l1d_req_addr <= {tag, idx, {`CORE_OFFSET_WIDTH{1'b0}}};
		l1d_req_size <= size;
		l1d_req_cop  <= `CORE_REQ_WRNC;
		l1d_req_wdata <= data;
    while(l1d_req_ack !== 1'b1) begin
      @(posedge clk)
      if(l1d_req_ack) data = l1d_ack_data;
    end
    l1d_req_val <= 1'b0;
 		$display("L1D WRNC size=%0d tag=%0h idx=%0h (%0t)", size, tag, idx, $time());
	endtask

	initial begin
		clk <= 0;
		sem = new(1);
		forever #10 clk <= ~clk;
	end

	initial begin
		rst <= 1;
		l1i_req_val <= 0;
		l1i_req_addr <= 0;
		l1d_req_val <= 0;
		wb_ack <= 0;
		wb_data <= 0;
		repeat(5) @(posedge clk);
		rst <= 0;
	end

	initial begin
		bit [31:0] l1i_data;
		bit [31:0] l1d_data;
		wait(rst == 0);
		/*l1i_read(0, 0, l1i_data);
		l1i_read(0, 1, l1i_data);

		// Check evict
		l1i_read(0, 0, l1i_data);
		l1i_read(1, 0, l1i_data);
		l1i_read(2, 0, l1i_data);
		l1i_read(3, 0, l1i_data);
		l1i_read(4, 0, l1i_data);
		l1i_read(5, 0, l1i_data);

		//l1d_read(0, 1, 4, l1d_data);
		//l1d_read(0, 1, 4, l1d_data);
		//l1d_nc_read(0, 2, 4, l1d_data);
		//l1d_nc_write(0, 2, 4, l1d_data);
		//l1d_read(0, 1, 4, l1d_data);
		l1d_nc_write(0, 2, 4, l1d_data);
		l1d_nc_write(0, 2, 4, l1d_data);
		l1d_nc_write(0, 2, 4, l1d_data);
		l1d_read(0, 1, 4, l1d_data);
		*/
		@(posedge clk);
		l1i_req_val  <= 1'b1;
		l1i_req_addr <= 32'h0000_0000;
		@(posedge clk);
		l1i_req_addr <= 32'h1000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h2000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h3000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h0000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h1000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h2000_0000;
		@(negedge clk);
		wait(l1i_req_ack);
		@(posedge clk);
		l1i_req_addr <= 32'h5000_0000;
		@(negedge clk);
		wait(l1i_req_ack);

		#1000ns;
		#1000;
		$finish();
	end

	initial begin
		int delay;
		forever begin
			@(posedge clk);
			if(wb_stb) begin
				//$display("%0t WB REQ ADDR=%0d", $time(), wb_adr);
				while(!sem.try_get());
				active_req++;
				sem.put();
			end
		end
	end

	initial begin
		int delay;
		bit [31:0] data;
		forever begin
			@(posedge clk);
			if(active_req > 0) begin
				//std::randomize(delay) with {delay inside {[0:5]};};
				delay = 10;
				repeat(delay) begin
					wb_ack <= 0;
					@(posedge clk);
				end
				wb_ack  <= 1;
				data = wb_data + 1;
				wb_data <= data;
				while(!sem.try_get());
				active_req--;
				sem.put();
				//$display("%0t WB ACK DATA=%0h", $time(), data);
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
		.l1d_req_val 	(l1d_req_val),
		.l1d_req_addr (l1d_req_addr),
		.l1d_req_cop 	(l1d_req_cop), 
		.l1d_req_wdata(l1d_req_wdata),
		.l1d_req_size (l1d_req_size),
		.l1d_req_be 	(l1d_req_be),
		.l1d_req_ack 	(l1d_req_ack),
		.l1d_ack_data (l1d_ack_data),
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