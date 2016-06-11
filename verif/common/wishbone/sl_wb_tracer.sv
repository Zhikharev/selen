// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME 		   : sl_wb_tracer.sv
// PROJECT 			   : Selen
// AUTHOR 			   : Grigoriy Zhiharev
// AUTHOR'S EMAIL  : gregory.zhiharev@gmail.com
// ----------------------------------------------------------------------------
// DESCRIPTION 		 :
// ----------------------------------------------------------------------------
// Версия  Дата      Автор         Описание
// 1.0 		 11.06.16 Zhikharev 		Начальная версия

`ifndef INC_SL_WB_TRACER
`define INC_SL_WB_TRACER

module sl_wb_tracer
	(
		wb_if wb_intf
	);

	string prefix;

	function void set_prefix(string name);
		prefix = name;
	endfunction

	function string get_cop();
		if(wb_intf.we) return("REG WRITE");
		return("REG READ");
	endfunction

	function logic [31:0] get_data();
		if(wb_intf.we) return(wb_intf.dat_o);
		return(wb_intf.dat_i);
	endfunction

	always @(wb_intf.clk) begin
		if(wb_intf.cyc & wb_intf.stb) begin
			string s;
			s = $sformatf("[%0s] %0s addr=0x%0h ", prefix, get_cop(), wb_intf.adr);
			wait(wb_intf.ack);
			if(!wb_intf.we) @(negedge wb_intf.clk);
			s = {s, $sformatf("data=0x%0h", get_data())};
			if($test$plusargs("WB_TRACE")) begin
				$display("%0s (%0t)", s, $time());
			end
		end
	end


endmodule

`endif