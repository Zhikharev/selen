/*always @*
begin
	if(reset)begin
		//hz2ctrl_loc = 1'b0;
		flashD_loc = 1'b1;
		flashE_loc = 1'b1;
		flashM_loc = 1'b1;
		flashW_loc = 1'b1;
		enbE_loc = 1'b0;
		enbM_loc = 1'b0;
		enbW_loc = 1'b0;
		enbD_loc = 1'b0;
		mux2_loc = 1'b0;
	end
	else begin
		//hz2ctrl_loc = 1'b0;
		flashD_loc = 1'b0;
		flashE_loc = 1'b0;
		flashM_loc = 1'b0;
		flashW_loc = 1'b0;
		
		if(~mux1)begin
			flashD_loc = 1'b1;
			flashE_loc = 1'b1;
			flashM_loc = 1'b1;
		end
		if((cmd_inE == lw_cmd)&&((rs1D == rdE)||(rs2D == rdE)))begin
			mux2_loc = 1'b1;
			enbD_loc = 1'b1;

			flashE_loc = 1'b1;

		end

		if((cmd_inE == jmp_cmd)&&(we_regW))begin

			enbE_loc = 1'b1;

			enbM_loc = 1'b1;

			enbW_loc = 1'b1;

			enbD_loc = 1'b1;

			if(done_in)begin

				hz2ctrl_loc = 1'b1;

			end

			else begin

				hz2ctrl_loc =1'b0;

			end

		end

	end

	if(stall_in)begin//TO DO 

		mux2_loc = 1'b1;

		enbE_loc = 1'b1;

		enbM_loc = 1'b1;

		enbW_loc = 1'b1;

		enbD_loc = 1'b1; 

	end

	else begin

		mux2_loc = 1'b0;

	end

end*/
/*
always @* begin
	if(reset)begin
		hz2ctrl_loc = 1'b1;
		nop_gen_loc <= 1'b0;
		flashD_loc = 1'b1;
		flashE_loc = 1'b1;
		flashM_loc = 1'b1;
		flashW_loc = 1'b1;
		enbE_loc = 1'b0;
		enbM_loc = 1'b0;
		enbW_loc = 1'b0;
		enbD_loc = 1'b0;
		mux2_loc = 1'b0;
	end
	/// pipilene's hazadrs
	else begin
		// lw bubble
		if((rdE == rs1D)||(rdE == rs2D)||(cmd_inE == lw_cmd))begin
			mux2_loc = 1'b1;
			nop_gen_loc =1'b1;
			enbD_loc = 1'b1;
		end
		else begin
			mux2_loc = mux2_loc;
			nop_gen_loc =nop_gen_loc;
			enbD_loc = enbD_loc;
		end
		// brnch misprediction penality 
		if(~mux1) begin
			flashD_loc = 1'b1;
			flashE_loc = 1'b1;
			flashM_loc = 1'b1;
		end
		else begin
			flashD_loc = flashD_loc;
			flashE_loc = flashE_loc;
			flashM_loc = flashM_loc;
		end
		// for jmp hazard if wrt_end is 1 thefore nop gen = 1'b1 and enbD = 1'b1 while wrt_enb = 1'b0; also be aware of rd = zero in jump ocomands becous there is not need to write smt in registe file
		if(cmd_inD == jmp_cmd)begin
			if(rdD == 5'b0)begin
				
			end
			else begin
				if(we_regW == 1'b1)begin
					enbD_loc = 1'b1;
					mux2_loc = 1'b1;
					nop_gen_loc = 1'b1;
				end
				else begin
					///////
				end
			end
		end
		else begin
			///////
		end
		//waiting for memory answer
	if(data_stb_out == 1'b1)begin
		mux2_loc = 1'b1;
		enbW_loc = 1'b1;
		enbM_loc = 1'b1;
		enbE_loc = 1'b1;
		enbD_loc = 1'b1;
	end
	else begin
		mux2_loc = mux2_loc;
		enbW_loc = enbW_loc;
		enbM_loc = enbM_loc;
		enbE_loc = enbE_loc;
		enbD_loc = enbD_loc;
	end
	end
end

*/



