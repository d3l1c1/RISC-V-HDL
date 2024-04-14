module alu_decoder (
    input [1:0] alu_2bit_op_i,
    input [2:0] funct3_i,
    input [6:0] funct7_i,
    input [4:0] rs_2_i,
    output reg[1:0] alu_inverters, // used to tell alu if it should invert any of it's inputs
    
    /*
    00 - invert none
    01 - invert 1st
    10 - invert 2nd
    11 - invert output
    */

    output reg[4:0] alu_op_o // signal that tells ALU precisely which operation to do
);

/*
    Operations opcodes for ALU

    00000 - add
    00001 - sub
    00010 - sll
    00011 - slt
    00100 - sltu
    00101 - xor
    00110 - srl
    00111 - or
    01000 - and
    01001 - sra
    01010 - mul
    01011 - mulh 
    01100 - mulhsu
    01101 - mulhu
    01110 - div
    01111 - divu
    10000 - rem
    10001 - remu
    10010 - rol
    10011 - ror
    10100 - max
    10101 - maxu
    10110 - min
    10111 - minu
    11000 - rev8
    11001 - orc.b
    11010 - cpop
    11011 - ctz
    11100 - clz
    11101 - sext.b
    11110 - sext.h
    11111 - zext.h
    
*/

    always @*
    begin
        
        alu_op_o = 5'b00000;
        alu_inverters = 2'b00; 
    
        if (alu_2bit_op_i == 2'b00) begin
            alu_op_o = 5'b00000; // add
        end 
        else if (alu_2bit_op_i == 2'b01) begin
            alu_op_o = 5'b00001; // sub
        end 
        else if (alu_2bit_op_i == 2'b10) begin // R type
            case(funct7_i)

            7'b0000000:
                case(funct3_i)
                    3'b000: alu_op_o = 5'b00000; // add
                    3'b001: alu_op_o = 5'b00010; // sll
                    3'b010: alu_op_o = 5'b00011; // slt
                    3'b011: alu_op_o = 5'b00100; // sltu
                    3'b100: alu_op_o = 5'b00101; // xor
                    3'b101: alu_op_o = 5'b00110; // srl
                    3'b110: alu_op_o = 5'b00111; // or
                    3'b111: alu_op_o = 5'b01000;// and
                    default: alu_op_o = 5'b00000;
                endcase
            7'b0100000:
                case(funct3_i) 
                    3'b111: begin alu_op_o = 5'b01000; alu_inverters = 2'b10; end// andn
                    3'b110: begin alu_op_o = 5'b00111; alu_inverters = 2'b10; end // orn
                    3'b100: begin alu_op_o = 5'b00101; alu_inverters = 2'b11; end// xnor
                    3'b000: alu_op_o = 5'b00001; // sub
                    3'b101: alu_op_o = 5'b01001;// sra
                default: alu_op_o = 5'b00000; 
                endcase
            7'b0000001: // MULs and DIVs
                case(funct3_i)
                    3'b000: alu_op_o = 5'b01010;// mul
                    3'b001: alu_op_o = 5'b01011;// mulh
                    3'b010: alu_op_o = 5'b01100;// mulhsu
                    3'b011: alu_op_o = 5'b01101;// mulhu
                    3'b100: alu_op_o = 5'b01110;// div
                    3'b101: alu_op_o = 5'b01111;// divu
                    3'b110: alu_op_o = 5'b10000;// rem
                    3'b111: alu_op_o = 5'b10001;// remu
                default: alu_op_o = 5'b00000;
                endcase
            7'b0110000: // rol, ror
                case(funct3_i)
                    3'b001: alu_op_o = 5'b10010;// rol
                    3'b101: alu_op_o = 5'b10011;// ror
                endcase
            7'b0000101: //max, maxu, min, minu
                case(funct3_i)
                    3'b110: alu_op_o = 5'b10100; // max
                    3'b100: alu_op_o = 5'b10101; // min
                    3'b101: alu_op_o = 5'b10110; // minu
                    3'b111: alu_op_o = 5'b10111; // maxu
                    default:  alu_op_o = 5'b00000;
                endcase    
            7'b0000100:
                    if(rs_2_i == 5'b00000 && funct3_i == 3'b100) begin
                        alu_op_o = 5'b11111; // zext.h
                    end else begin
                        alu_op_o = 5'b00000;
                    end
            default:  alu_op_o = 5'b00000;

            endcase
        end 
        else if (alu_2bit_op_i == 2'b11) begin // I type instructions
            // all I type instructions have opcode 0010011
            case(funct7_i)
                7'b0110000:
                    if(funct3_i == 3'b001) begin
                        case(rs_2_i)
                            5'b00000: alu_op_o = 5'b11100; // clz
                            5'b00001: alu_op_o = 5'b11011; // ctz
                            5'b00010: alu_op_o = 5'b11010; // cpop
                            5'b00100: alu_op_o = 5'b11101; // sext.b
                            5'b00101: alu_op_o = 5'b11110; // sext.h
                            default: alu_op_o = 5'b00000;
                        endcase
                    end else begin
                        alu_op_o = 5'b00000;
                    end
                7'b0110100:
                    if(rs_2_i == 5'b11000 && funct3_i == 3'b101) begin
                        alu_op_o = 5'b11000; // rev8
                    end else begin
                         alu_op_o = 5'b00000;
                    end
                7'b0010100:
                    if(rs_2_i == 5'b00111 && funct3_i == 3'b101) begin
                        alu_op_o = 5'b11001; // orc.b
                    end else begin
                        alu_op_o = 5'b00000;
                    end

                default:

                        case(funct3_i) 
                            3'b000: alu_op_o = 5'b00000; // addi
                            3'b001: alu_op_o = 5'b00010; // slli
                            3'b010: alu_op_o = 5'b00011; // stli
                            3'b011: alu_op_o = 5'b00100; // sltiu
                            3'b100: alu_op_o = 5'b00101; // xori
                            3'b101: alu_op_o = 5'b00110; // srli
                            3'b110: alu_op_o = 5'b00111; // ori
                            3'b111: alu_op_o = 5'b01000; // andi
                            default: alu_op_o = 5'b00000;
                        endcase

            endcase

        end 
        else 
            begin
                alu_op_o = 5'b00000; // Default value, you may want to adjust it based on your requirements
            end
    end

endmodule
