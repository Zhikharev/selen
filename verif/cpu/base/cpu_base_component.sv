// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : cpu_base_component.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_CPU_BASE_COMPONENT
`define INC_CPU_BASE_COMPONENT

class cpu_base_component; 
  
	virtual wishbone_if wbi_intf;
	virtual wishbone_if wbd_intf;
	virtual reset_if    rst_intf;

  function new (virtual wishbone_if wbi_if, virtual wishbone_if wbd_if, reset_if rst_if);
    this.wbi_intf = wbi_if;
    this.wbd_intf = wbd_if;
    this.rst_intf = rst_if;
  endfunction 
endclass

`endif