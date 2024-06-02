module immediate (
    input [31:0] instruction_i,
    output reg[31:0] immediate_extended_o
);

    always @(*)
    begin
        case (instruction_i[6:0])   // Checking the opcode
            7'b0000011, 7'b0010011, 7'b1100111: // JALR, loads, immediate instructions
                begin
                    if(instruction_i[31] == 1'b0) begin
                        immediate_extended_o = {20'b00000000000000000000, instruction_i[31:20]};
                    end 
                    else begin
                        immediate_extended_o = {20'b11111111111111111111, instruction_i[31:20]};
                    end
                end
            7'b1100011: // Branches
                begin
                    if(instruction_i[31] == 1'b0) begin
                        immediate_extended_o = {19'b0000000000000000000, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
                    end 
                    else begin
                        immediate_extended_o = {19'b1111111111111111111, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
                    end
                end
            7'b0100011: // Store
                begin
                    if(instruction_i[31] == 1'b0) begin
                        immediate_extended_o = {20'b00000000000000000000, instruction_i[31:25], instruction_i[11:7]};
                    end 
                    else begin
                        immediate_extended_o = {20'b11111111111111111111, instruction_i[31:25], instruction_i[11:7]};
                    end
                end
            7'b0110111: // LUI, AUIPC
                /*
                begin
                    if(instruction_i[31] == 1'b0) begin
                        immediate_extended_o = {12'b000000000000, instruction_i[31:12]};
                    end 
                    else begin
                        immediate_extended_o = {12'b111111111111, instruction_i[31:12]};
                    end
                end
                */
                immediate_extended_o = {instruction_i[31:12],12'b000000000000};
                
            7'b1101111: // JAL
                begin
                    if(instruction_i[31] == 1'b0) begin
                        immediate_extended_o = {11'b00000000000, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
                    end 
                    else begin
                        immediate_extended_o = {11'b11111111111, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
                    end
                end
            default:
                immediate_extended_o = 32'b00000000000000000000000000000000;
        endcase
    end
endmodule
