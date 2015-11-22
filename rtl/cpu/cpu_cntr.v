module cpu_ctrl(
	input[1:0] fnct7,
	input[2:0] fnct,
	input[6:0] opcode,
	input hz2ctrl,
	output[1:0] be_mem,
	output we_mem,
	output we_reg,
	output[1:0] brn_type,
	output[2:0] sx_cntl,
	output[3:0] alu_cntr,
	output alu_s_u,
	output mux10,
	output mux9,
	output mux8,
	output mux8_2,
	output mux8_3,
	output mux7,
	output mux6,
	output mux5,
	output mux4,
	output mux4_2,
	output mux3,
	output[1:0] cmd,
	output rubish//not right comand 

);
localparam ADD = 4'b0000;
localparam SLT = 4'b0001;
localparam SLTU = 4'b0010;
localparam AND  = 4'b0011;
localparam OR = 4'b0100;
localparam XOR = 4'b0101;
localparam SLL = 4'b0110;
localparam SRL = 4'b0111;
localparam SUB  = 4'b1000;
localparam SRA = 4'b1001;
localparam AM = 4'b1010;

localparam BP =2'b00;
localparam LH =2'b01;
localparam LB =2'b10;

localparam R = 7'b0000011;
localparam R_I = 7'b1000011;
localparam U_LUI = 7'b0100011;
localparam U_AUIPC = 7'b0110011;
localparam SB = 7'b0010011;
localparam UJ = 7'b0001011;
localparam S = 7'b0001111;
localparam I = 7'b0000111;

localparam FULL = 2'b00;
localparam HALF = 2'b01;
localparam BYTE = 2'b10;
localparam UPPER = 2'b11;

localparam SIGN = 1'b1;
localparam UNSIGN = 1'b0;

localparam EQ = 3'b100;
localparam NE = 3'b101;
localparam LT = 3'b110;
localparam GE = 3'b111;

localparam lw_cmd = 2'b11;
localparam st_cmd = 2'b10;
localparam jmp_cmd = 2'b01;
localparam other = 2'b00;

reg loc10,loc9,loc8,loc8_2,loc8_3,loc7,loc6,loc5,loc4,loc4_2,loc3,loc1;
reg we_mem_loc,we_reg_loc;
reg s_u_loc;
reg[1:0]be_mem_loc;
reg[1:0] cmd_loc;
reg[2:0] brn_loc,sx_loc;
reg[3:0]alu_loc;
reg rubish_loc;
reg rubish_alu_loc;
////// always for muxs and,be and sx
always @*
begin
	///////R type 
	case(opcode)
		R:begin
			loc10 = 1'b0;
			loc9 = 1'b0;
			loc8 = 1'b0;
			loc8_2 = 1'b0;
			loc8_3 = 1'b0;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc5 = 1'b1;
			loc4 = 1'b1;
			loc4_2 = 1'b1;
			loc3 = 1'b0;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b1;
			be_mem_loc = 2'bxx;
			cmd_loc = other;
			rubish_loc = 1'b0;
			sx_loc = {SIGN,FULL};
		end
		R_I:begin
			loc10 = 1'b0;
			loc9 = 1'b0;
			loc8 = 1'b1;
			loc8_2 = 1'b0;
			loc8_3 = 1'b0;
			loc7 = 1'b0;
			loc6 = 1'bx;
			loc5 = 1'b1;
			loc4 = 1'b1;
			loc4_2 = 1'b1;
			loc3 = 1'b0;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b1;
			be_mem_loc = 2'bxx;;
			cmd_loc = other;
			sx_loc = {SIGN,FULL};
			rubish_loc = 1'b0;
		end
		U_LUI:begin///////////////
			loc10 = 1'b1;
			loc9 = 1'bx;
			loc8 = 1'bx;
			loc8_2 = 1'bx;
			loc8_3 = 1'bx;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc5 = 1'b1;
			loc4 = 1'b1;
			loc4_2 = 1'b1;
			loc3 = 1'b0;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b1;
			be_mem_loc = 2'bxx;
			cmd_loc = other;
			sx_loc = {SIGN,FULL};
			rubish_loc = 1'b0;
		end
		U_AUIPC:begin
			loc10 = 1'b0;
			loc9 = 1'b0;
			loc8 = 1'bx;
			loc8_2 = 1'b1;
			loc8_3 = 1'b1;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc5 = 1'b1;
			loc4 = 1'b1;
			loc4_2 = 1'b1;
			loc3 = 1'b0;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b1;
			be_mem_loc = 2'bxx;
			cmd_loc = other;
			sx_loc = {SIGN,FULL};
			rubish_loc = 1'b0;
		end
		SB:begin
			loc10 = 1'b0;
			loc9 = 1'bx;
			loc8 = 1'b1;
			loc8_2 = 1'b0;
			loc8_3 = 1'b0;
			loc7 = 1'b1;
			loc6 = 1'b0;
			loc5 = 1'bx;
			loc4 = 1'b1;
			loc4_2 = 1'b1;
			loc3 = 1'b0;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b0;
			be_mem_loc = 2'bxx;
			cmd_loc = other;
			sx_loc = 3'bxxx;
			rubish_loc = 1'b0;
		end
		UJ:begin//jal
			loc10 = 1'bx;
			loc9 = 1'bx;
			loc8 = 1'bx;
			loc8_2 = 1'bx;
			loc8_3 = 1'bx;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc4 = 1'bx;
			loc4_2 = 1'bx;
			loc3 = 1'b1;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b1;
			be_mem_loc = FULL;
			cmd_loc = jmp_cmd;
			rubish_loc = 1'b0;
			sx_loc = 3'bxxx;
			if(hz2ctrl) begin
				loc5 = 1'b0;
			end
			else loc5 = 1'b1;
		end
		I:begin
			if(fnct == 3'b000)begin
				loc10 = 1'bx;
				loc9 = 1'bx;
				loc8 = 1'bx;
				loc8_2 = 1'bx;
				loc8_3 = 1'bx;
				loc7 = 1'b1;
				loc6 = 1'bx;
				loc4 = 1'b0;
				loc4_2 = 1'b0;
				loc3 = 1'b0;
				sx_loc = 3'bxxx;
				we_mem_loc = 1'b0;
				we_reg_loc = 1'b1;
				be_mem_loc = FULL;
				cmd_loc = jmp_cmd;
				rubish_loc = 1'b0;
				if(hz2ctrl) begin
					loc5 = 1'b0;
				end
				else loc5 = 1'b1;
			end
			else begin
				loc10 = 1'b0;
				loc9 = 1'b1;
				loc8 = 1'b1;
				loc8_2 = 1'b0;
				loc8_3 = 1'b0;
				loc7 = 1'b0;
				loc6 = 1'bx;
				loc5 = 1'b1;
				loc4 = 1'b1;
				loc4_2 = 1'b1;
				loc3 = 1'b0;
				//loc2 = 1'b0;
				cmd_loc = lw_cmd;
				rubish_loc = 1'b0;
				case(fnct)
					3'b001:begin
						//LW
						be_mem_loc = FULL;
						sx_loc ={SIGN,FULL};
					end
					3'b010:begin
						//LH
						be_mem_loc = HALF;
						sx_loc ={SIGN,HALF};
					end
					3'b011:begin
						//LHU
						be_mem_loc = HALF;
						sx_loc = {UNSIGN,HALF};
					end
					3'b100:begin
						//LB
						be_mem_loc = BYTE;
						sx_loc = {SIGN,BYTE};
					end
					3'b101:begin
						//LBU
						be_mem_loc = BYTE;
						sx_loc = {UNSIGN,BYTE};
					end
				endcase
			end
		end
		S:begin
			loc10 = 1'b0;
			loc9 = 1'bx;
			loc8 = 1'bx;
			loc8_2 = 1'b0;
			loc8_3 = 1'b0;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc5 = 1'b0;
			loc4 = 1'bx;
			loc4_2 = 1'bx;
			loc3 = 1'bx;
			we_mem_loc = 1'b1;
			we_reg_loc = 1'b0;
			cmd_loc = st_cmd;
			rubish_loc = 1'b0;
			case(fnct)
				3'b001:begin
					sx_loc = {SIGN,FULL};
				end
				3'b010:begin
					sx_loc = {SIGN,HALF};
				end
				3'b011:begin
					sx_loc = {SIGN,BYTE};
				end
			endcase
		end
		default: begin/// defualt is don't write to reg and mem 
			loc10 = 1'bx;
			loc9 = 1'bx;
			loc8 = 1'bx;
			loc8_2 = 1'bx;
			loc8_3 = 1'bx;
			loc7 = 1'bx;
			loc6 = 1'bx;
			loc5 = 1'bx;
			loc4 = 1'bx;
			loc4_2 = 1'bx;
			loc3 = 1'bx;
			we_mem_loc = 1'b0;
			we_reg_loc = 1'b0;
			be_mem_loc = 2'bxx;
			cmd_loc = 2'bxx;
			rubish_loc = 1'b1;
			sx_loc = {SIGN,FULL};
		end
	endcase

end
///// always for alu controll
always @* 
begin
	case(opcode)
		R:begin
			brn_loc = 3'b0xx;
			if(fnct7 == 2'b00)begin
				case(fnct)
					3'b000: begin
						alu_loc = ADD;
						s_u_loc = SIGN;
					end
					3'b001: begin
						alu_loc = SLT;
					end
					3'b010: begin
						alu_loc = SLTU;
					end
					3'b011: begin
						alu_loc = AND;
						s_u_loc = SIGN;
					end
					3'b100: begin
						alu_loc = OR;
						s_u_loc = SIGN;
					end
					3'b101: begin
						alu_loc = XOR;
						s_u_loc = SIGN;
					end
					3'b110: begin
						alu_loc = SLL;
						s_u_loc = SIGN;
					end
					3'b111: begin
						alu_loc = SRL;
						s_u_loc = SIGN;
					end
				endcase
			end		
			else begin
				case(fnct)
					3'b000:begin
						alu_loc = SUB;
						s_u_loc = SIGN;
					end
					3'b001:begin
						alu_loc = SRA;
						s_u_loc = SIGN;
					end
					3'b010:begin
						alu_loc = AM;
						s_u_loc = SIGN;
					end
					default: begin
						alu_loc = SUB;
						s_u_loc = SIGN;
					end
					endcase
			end
		end/////end R type
		R_I:begin
			brn_loc = 3'b0xx;
			case(fnct)
				3'b000: begin
					alu_loc = ADD;
					s_u_loc = SIGN;
				end
				3'b001: begin
					alu_loc = SLT;
				end
				3'b010: begin
					alu_loc = AND;
				end
				3'b011: begin
					alu_loc = OR;
					s_u_loc = SIGN;
				end
				3'b100: begin
					alu_loc = XOR;
					s_u_loc = SIGN;
				end
				3'b101: begin
					alu_loc = SLL;
					s_u_loc = SIGN;
				end
				3'b110: begin
					alu_loc = SRL;
					s_u_loc = SIGN;
				end
				3'b111: begin
					alu_loc = SRA;
					s_u_loc = SIGN;
				end
			endcase
		end/////end R_I
		U_LUI:begin
			alu_loc = SLL;// don't care 
		end
		U_AUIPC:begin
			alu_loc = ADD;
		end
		SB:begin
			case(fnct)
				3'b000: begin
					///// BEQ
					alu_loc = SUB;
					s_u_loc = SIGN;
					brn_loc = {1'b1,EQ};
				end
				3'b001: begin
					////BNE
					alu_loc = SUB;
					s_u_loc = SIGN;
					brn_loc = {1'b1,NE};
				end
				3'b010: begin
					////BLT
					alu_loc = SUB;
					s_u_loc = SIGN;
					brn_loc = {1'b1,LT};
				end
				3'b011: begin
					/////BLTU
					alu_loc = SUB;
					s_u_loc = UNSIGN;
					brn_loc = {1'b1,LT};
				end
				3'b100: begin
					////BGE
					alu_loc = SUB;
					s_u_loc = SIGN;
					brn_loc = {1'b1,GE};
				end
				3'b101: begin
					///BGEU
					alu_loc = SUB;
					s_u_loc = SIGN;
					brn_loc = {1'b1,GE};
				end
				default: begin
					alu_loc = SUB;
					s_u_loc = SIGN;
					rubish_loc =1'b1;
				end
			endcase
		end
		UJ:begin
			
		end
		I:begin
			case(fnct)
				3'b000:begin
				end
				default:begin
					alu_loc = ADD;
					s_u_loc = SIGN;
				end
			endcase
		end
		S:begin
			case(fnct)
				3'b000:begin
					rubish_alu_loc =1'b1;
				end
				default:begin
					alu_loc = ADD;
					s_u_loc = SIGN;
				end
			endcase
		end
	endcase
end
assign mux10 = loc10;
assign mux9 = loc9;
assign mux8 = loc8;
assign mux8_2 = loc8_2;
assign mux8_3 = loc8_3;
assign mux7 = loc7;
assign mux6 = loc6;
assign mux5 = loc5;
assign mux4 = loc4;
assign mux4_2 = loc4_2;
assign mux3 = loc3;
assign mux1 = loc1;
assign we_mem = we_mem_loc;
assign we_reg = we_reg_loc;
assign be_mem = be_mem_loc;
assign brn_type = brn_loc;
assign sx_cntl = sx_loc;
assign alu_cntr = alu_loc;
assign alu_s_u = s_u_loc;
assign cmd = cmd_loc;
assign rubish = rubish_loc;
endmodule
