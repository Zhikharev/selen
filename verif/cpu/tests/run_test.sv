// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// FILE NAME      : run_test.sv
// PROJECT        : Selen
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ----------------------------------------------------------------------------
// DESCRIPTION    : 
// ----------------------------------------------------------------------------

`ifndef INC_RUN_TEST
`define INC_RUN_TEST

`run_test(`if_type)

	string TESTNAME;
      
  initial begin
  	if($value$plusargs("TESTNAME=%s", TESTNAME)) begin
  		case(TESTNAME)
  			"draft_test": begin
  				draft_test test;
  				test = new(i_intf, d_intf, rst_intf);
  				test.build_phase();
  				test.run_phase();
  				test.report_phase();
  			end
        "direct_test": begin
          direct_test test;
          test = new(i_intf, d_intf, rst_intf);
          test.build_phase();
          test.run_phase();
          test.report_phase();
        end
  			"1st_test_seq":begin
					certain_inst test;
					test = new(i_intf, d_intf, rst_intf);
					test.build_phase();
					test.run_phase();
					test.report_phase(); 			
  			end
  		 "bp_test_seq":begin
					bp_inst test;
					test = new(i_intf, d_intf, rst_intf);
					test.build_phase();
					test.run_phase();
					test.report_phase(); 			
				end
  		 "ADDI_test_seq":begin
					ADDI_inst test;
					test = new(i_intf, d_intf, rst_intf);
					test.build_phase();
					test.run_phase();
					test.report_phase(); 			
				end
			endcase
  	end
  	else begin 
      $fatal("Undefined TESTNAME");
  	end
  end
endprogram

`endif
