module cpu_top (
	input core_sys_clk,    
	input core_sys_rst  	
	//instruction inteface
	output 					i_req_val,
	output[31;0] 		i_req_addr,
	input 					i_req_ack,
	input[31:0] 		i_ack_rdata
	//data interface 
	output 					d_req_val,
	output[31:0] 		d_req_addr,
	output[2:0]			d_req_cop,
	output[31:0] 		d_req_wdata,
	output[2:0] 		d_req_size,
	input						d_req_ack,
	input[31:0]			d_ack_rdata
);

endmodule