module cpu_cntr(
	input[6:0] opcode,
	input[2:0] fnct,
	input [1:0] fnct7,
	output mux_1,
	output mux_2_1,
	output mux_2_2,
	output mux_3,
	output mux_4,
	output[1:0] mux_5,
	output mux_6,
	output[1:0] sx_2_cntr,
	output[3:0] alu_cntr,
	output s_u_alu,
	output s_u_sx,
	output we_r,
	output we_m,
	output brch,
	output[1:0] reg_be,
	output lw,
);
reg locm_1,locm_2_1,locm_2_2,locm_3,locm_4,locm_6;
reg [1:0] loc_sx_2_cntr,locm_5,loc_reg_be;
reg[3:0] loc_alu_cntr;
reg loc_s_u_alu,loc_s_u_sx,loc_we_r,loc_wr_m,loc_brch,loc_lw;

localparam R = 7'b11;
localparam R_I = 7'b1000011;
localparam I = 7'b0000111;
localparam S = 7'b0001111;
localparam SB = 7'b0010011;
localparam UJ = 7'b0001011;

localparam ADD = 4'b0000;
localparam SLT = 4'b0001;
localparam AND  = 4'b0010;
localparam XOR = 4'b0011;
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


always @*
begin
	case(opcode) 
		R:begin
			locm_1 = 1'b0;
			locm_2_1 =1'bx;
			locm_2_2 = 1'b0;
			locm_3 = 1'b0;
			locm_4 = 1'b0;	
			locm_5 = 2'b11;
			loc_we_r = 1'b1;
			locm_6 = 1'bx;
			loc_we_m =1'b0;
		end	
		R_I:begin
			locm_1 = 1'b0;
			locm_2_1 =1'bx;
			locm_2_2 = 1'b0;
			locm_3 = 1'b1;
			locm_4 = 1'b0;	
			locm_5 = 2'b11;
			loc_we_r = 1'b1;
			locm_6 = 1'bx;
			loc_we_m =1'b0;
		end
		I:begin
			if(fnct == 3'b0)begin
				locm_1 = 1'b1;
				locm_5 = 2'b01;	
				locm_6 = 1'b0;
			end
			else begin
				locm_1 = 1'b0;
				locm_5 = 2'b11;
				locm_6 = 1'bx;
			end
			locm_2_1 =1'bx;
			locm_2_2 = 1'b0;
			locm_3 = 1'b1;
			locm_4 = 1'b1;	
			loc_we_r = 1'b1;
			loc_we_m =1'b0;
		end
		UJ:begin//// problems are there now
			locm_1 = 1'b0;
			locm_2_1 =1'bx;
			locm_2_2 = 1'bx;
			locm_3 = 1'bx;
			locm_4 = 1'bx;	
			locm_5 = 2'b11;
			loc_we_r = 1'b1;
			locm_6 = 1'b1;//
			loc_we_m =1'b0;
		end
		SB:begin
			locm_1 = 1'bx;
			locm_2_1 =1'b1;
			locm_2_2 = 1'b1;
			locm_3 = 1'b0;
			locm_4 = 1'bx;	
			locm_5 = 2'b10;
			loc_we_r = 1'b0;
			locm_6 = 1'b0;//
			loc_we_m =1'b0;
		end
		S:begin
			loc_we_m =1'b0;
			locm_1 = 1'b1;
			locm_2_1 =1'b1;//
			locm_2_2 = 1'b1;//
			locm_3 = 1'b1;
			locm_4 = 1'b1;	
			locm_5 = 2'b11;
			loc_we_r = 1'b1;
			locm_6 = 1'b0;//
		end
	endcase 	
	
end
always @*
begin
//// for R type begin
	if((fnct7 == 7'b0)&&(opcode == R))begin
		loc_s_u_se = 1'bx;
		loc_sx_2 = 2'b00;
		case(fnct)
			3'b000: begin
				loc_alu_cntr = ADD;
				loc_s_u_alu = 1'b1;
			end
			3'b001:begin 
				loc_alu_cntr = SLT;
				loc_s_u_alu = 1'b1;
			end	
			3'b010:begin 
				loc_alu_cntr = SLTU;
				loc_s_u_alu = 1'b0;
			end	
			3'b011:begin 
				loc_alu_cntr = AND;
				loc_s_u_alu = 1'b1;
			end	
			3'b100:begin 
				loc_alu_cntr = OR;
				loc_s_u_alu = 1'b1;
			end	
			3'b101:begin 
				loc_alu_cntr = XOR;
				loc_s_u_alu = 1'b1;
			end	
			3'b110:begin 
				loc_alu_cntr = SLL;
				loc_s_u_alu = 1'b1;
			end	
			3'b111:begin 
				loc_alu_cntr = SRL;
				loc_s_u_alu = 1'b1;
			end	
		endcase
	end
	if((fnct7==7'b0100000)&&(opcode == R))begin
				loc_s_u_se = 1'bx;
				loc_sx_2 = 2'b00;
				case(fnct)
					3'b000:begin 
						loc_alu_cntr = SUB;
						loc_s_u_alu = 1'b1;
					end	
					3'b001:begin 
						loc_alu_cntr = SRA;
						loc_s_u_alu = 1'b1;
					end	
					3'b010:begin 
						loc_alu_cntr = AM;
						loc_s_u_alu = 1'b1;
					end	


				endcase	
////end
/// for R_T type begin
if(opcode == R_I)begin
		loc_s_u_se = 1'bx;
		loc_sx_2 = 2'b00;
		case(fnct)
			3'b000: begin
				loc_alu_cntr = ADD;
				loc_s_u_alu = 1'b1;
			end
			3'b001:begin 
				loc_alu_cntr = SLT;
				loc_s_u_alu = 1'b1;
			end	
			3'b010:begin 
				loc_alu_cntr = AND;
				loc_s_u_alu = 1'b0;
			end	
			3'b011:begin 
				loc_alu_cntr = OR;
				loc_s_u_alu = 1'b1;
			end	
			3'b100:begin 
				loc_alu_cntr = XOR;
				loc_s_u_alu = 1'b1;
			end	
			3'b101:begin 
				loc_alu_cntr = SLL;
				loc_s_u_alu = 1'b1;
			end	
			3'b110:begin 
				loc_alu_cntr = SRL;
				loc_s_u_alu = 1'b1;
			end	
			if((fnct7 == 7'b0)&&(opcode == R_I))begin
				case(fnct)
					3'b000: begin
						loc_alu_cntr = ADD;
						loc_s_u_alu = 1'b1;
					end
					3'b001:begin 
						loc_alu_cntr = SLT;
						loc_s_u_alu = 1'b1;
					end	
					3'b010:begin 
						loc_alu_cntr = AND;
						loc_s_u_alu = 1'b0;
					end	
					3'b011:begin 
						loc_alu_cntr = OR;
						loc_s_u_alu = 1'b1;
					end	
					3'b100:begin 
						loc_alu_cntr = XOR;
						loc_s_u_alu = 1'b1;
					end	
					3'b101:begin 
						loc_alu_cntr = SLL;
						loc_s_u_alu = 1'b1;
					end	
					3'b110:begin 
						loc_alu_cntr = SRL;
						loc_s_u_alu = 1'b1;
					end	
					3'b111:begin 
						loc_alu_cntr = SRA
						loc_s_u_alu = 1'b1;
					end	
			
				endcase
			end

		endcase
	end
///end
/// I type begin
	if((opcode == I)) begin
		loc_alu_cntr = ADD;
		case(fnct)
			3'b000:begin
				loc_se_2_cntr = 2'bx;
				loc_s_u_sx = 1'bx; 
			end   
			3'b001:begin
				loc_se_2_cntr = BP;
				loc_s_u_sx = 1'bx; 
			end   	
			3'b010:begin
				loc_se_2_cntr = LH;
				loc_s_u_sx = 1'b1; 
			end   
			3'b011:begin
				loc_se_2_cntr = LH;
				loc_s_u_sx = 1'b0; 
			end
			3'b100:begin
				loc_se_2_cntr = LB;
				loc_s_u_sx = 1'b1; 
			end
			3'b101:begin
				loc_se_2_cntr = LB;
				loc_s_u_sx = 1'b0; 
			end
			default: loc_se_2_cntr = BP;
		endcase
	end
///emd
///SB type begin
	if(opcode == SB)begin
		loc_alu_cntr = SUB;
		case(fnct)
			3'b011: loc_s_u_alu = 1'b0;
			3'b101: loc_s_u_alu = 1'b0;
			default: loc_s_u_alu = 1'b1;
		endcase;
	end
///end
//S type begin
	if(opcode == S)begin
		case(fnct)
			3'b001: loc_reg_be = 2'b01;
			3'b010: loc_reg_be = 2'b11;
			3'b011: loc_reg_be = 2'b10;
		endcase
	end
//end
end


endmodule
