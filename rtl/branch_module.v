`timescale 1ns / 1ps

module branch_module(
        
        input wire [31:0] operand1,
        input wire [31:0] operand2,
        input wire [6:0] opcode_i,
        input wire [2:0] funct3_i,
        
        output wire branch_condition_o
        
    );
    
    reg branch_o;
    
    wire signed [31:0] op1_s, op2_s;
    wire unsigned [31:0] op1_i, op2_u;
    
    assign op1_s = operand1;
    assign op2_s = operand2;
    assign op1_u = operand1;
    assign op2_u = operand2;
    
    
    always @(operand1, operand2, funct3_i, opcode_i)
    begin
            
           if(opcode_i == 7'b1100011) begin
            
                case(funct3_i)
                3'b000: //beq
                    if(operand1 == operand2) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                3'b001: // bne
                    if(operand1 != operand2) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                3'b100: // blt
                    if(op1_s < op2_s) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                3'b101: // bge
                    if(op1_s >= op2_s) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                3'b110: // bltu
                    if(op1_u < op2_u) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                3'b111: // bgeu
                    if(op1_u > op2_u) begin
                        branch_o = 1'b1;
                    end
                    else begin
                        branch_o = 1'b0;
                    end
                default:
                    branch_o = 1'b0;
                endcase
           
           end
           
           else begin
           
            branch_o = 1'b0;
           
           end
            
    end
    
    assign branch_condition_o = branch_o;
    
endmodule
