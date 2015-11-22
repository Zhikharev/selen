module alu(
    input[31:0] srca,
    input[31:0] srcb,
    input[3:0] alu_cntl,
    input[4:0] shamt,
    output[31:0] resalt,
    output zero_flag,
    output slt_flag
);

localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam AND = 4'b0010;
localparam OR =  4'b0011;
localparam XOR = 4'b0100;
localparam SLL = 4'b0101;
localparam SRL = 4'b0110;
localparam SRA = 4'b0111;
localparam AM =  4'b1000;
localparam CMP = 4'b1001;

reg[31:0] loc_resalt;
always @*
begin  
    case(alu_cntl) 
        : begin
            loc_resalt = srca + srcb;
        end  
        
        : begin
            
        end



    endcase 
end
endmodule 
