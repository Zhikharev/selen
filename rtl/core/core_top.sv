// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME            	: cpu_top.sv
// PROJECT                : Selen
// AUTHOR                 : Alexsandr Bolotnokov
// AUTHOR'S EMAIL 				:	AlexBolotnikov@gmail.com 			
// ----------------------------------------------------------------------------
// DESCRIPTION        		: top module for pipeline CPU include interconection betwin pipline module and CRS module 
// ----------------------------------------------------------------------------
module cpu_top (
	input core_sys_clk,    
	input core_sys_rst  	
	//instruction inteface
	output 				i_req_val,
	output[31;0] 		i_req_addr,
	input 				i_req_ack,
	input[31:0] 		i_ack_rdata
	//data interface 
	output 				d_req_val,
	output[31:0] 		d_req_addr,
	output[2:0]			d_req_cop,
	output[31:0] 		d_req_wdata,
	output[2:0] 		d_req_size,
	input				d_req_ack,
	input[31:0]			d_ack_rdata
);
wire[31:0] csr2pl_cash_uncahe_addr;
core_pipeline pipeline(
.clk(clk),
.rst_n(rst_n),
.pl_csr_addr_cach_uncash(csr2pl_cash_uncahe_addr),
//l1i
.pl_l1i_ack_rdata_in(i_ack_rdata),
.pl_l1i_ack_in(i_req_ack),
.pl_l1i_req_val_out(i_req_val),
.pl_l1i_req_aadr_out(i_req_addr),
//l1d
.pl_l1d_req_val_out(d_req_val),
.pl_l1d_req_addr_out(d_req_addr),
.pl_l1d_req_cop_out(d_req_cop),
.pl_l1d_req_wdata_out(d_req_wdata),
.pl_l1d_req_size_out(d_req_size),
.pl_l1d_ack_ack_in(d_req_ack),
.pl_l1d_ack_rdata_in(d_ack_rdata)
);

core_csr csr(
.clk(clk),
.rst_n(rst_n),
.csr_data_wrt(),
.csr_addr(),
.csr_data_out(csr2pl_cash_uncahe_addr),
.csr_time_out(),
);

endmodule