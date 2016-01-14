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

typedef virtual wishbone_if wb_vif_t;
typedef virtual core_if 		core_vif_t;

class cpu_base_component #(type VIF_T = wb_vif_t); 
  
	VIF_T 	i_intf_m;
	VIF_T 	d_intf_m;
	virtual reset_if  rst_intf_m;

  function new (VIF_T i_if, VIF_T d_if,  virtual reset_if rst_if);
    this.i_intf_m = i_if;
    this.d_intf_m = d_if;
    this.rst_intf_m = rst_if;
  endfunction 
endclass

// -------------------------------------------------------------
// MACROS
// -------------------------------------------------------------
`ifndef if_type 
  `define if_type core
`endif

`define env_inst(T)\
  cpu_``T``_env env;

`define test_utils(T)\
  function new (virtual ``T``_if i_intf, virtual ``T``_if d_intf, virtual reset_if rst_intf);\
    super.new(i_intf, d_intf, rst_intf);\
    env = new(i_intf, d_intf, rst_intf);\
  endfunction

`define run_test(T)\
  program run_test (\
  ``T``_if i_intf,\
  ``T``_if d_intf,\
  reset_if    rst_intf);

`endif