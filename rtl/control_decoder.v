module control_decoder(

        input wire[6:0] opcode_i, // instruction opcode
        input wire[2:0] funct3_i, // funct3 field in instruction word

        output reg mem_to_reg_o, // if register bank will be written by this instruction
        output reg[1:0] data_mem_we_o, // does data_mem need to be written to (enable signal)
        output reg rd_we_o, // enable signal for register bank if load is executed
        output reg alu_src_b_o, // controls mux for ALU inputs (choose between  rs2 or imm)
        output reg branch_o, // if instruction is branch type
        output reg[1:0] alu_2bit_op_o, // controls ALU operations for store, load and other
        output reg rs1_in_use_o, // if register rs1 is used in this instruction
        output reg rs2_in_use_o, // if register rs2 is used in this instruction
        output reg pc_operand_o // mux control signal
    );

    always @*
    begin
        case(opcode_i)
        7'b0110011: // R type instructions
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b0;
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b10;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b1;
                pc_operand_o  = 1'b0; 
            end
        7'b0010011: // I type instructions
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b11;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b0; 
            end 
        7'b0000011: // Load instructions
            begin
                mem_to_reg_o = 1'b1;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b0; 
            end
        7'b1100011: // B type instructions
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b0;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b1;
                alu_2bit_op_o = 2'b01;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b1;
                pc_operand_o  = 1'b0; 
            end
        7'b0100011: // S type instructions
            begin
                mem_to_reg_o = 1'b0;

                case(funct3_i)
                    3'b000: data_mem_we_o = 2'b01; // SB
                    3'b001: data_mem_we_o = 2'b10; // SH
                    3'b010: data_mem_we_o = 2'b11; // SW
                    default: data_mem_we_o = 2'b00;
                endcase

                rd_we_o = 1'b0;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b1;
                pc_operand_o  = 1'b0; 
            end
        7'b1100111: // JALR
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b1;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b1;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b1; 
            end
        7'b1101111: // JAL
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b1;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b0;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b0;
            end
        7'b0010111: // AUIPC
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b0;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b1;  
            end
        7'b0110111: // LUI
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b1;
                alu_src_b_o = 1'b1; // pass imm
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b0;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b0;   
            end
        default:
            begin
                mem_to_reg_o = 1'b0;
                data_mem_we_o = 2'b00;
                rd_we_o = 1'b0;
                alu_src_b_o = 1'b0;
                branch_o = 1'b0;
                alu_2bit_op_o = 2'b00;
                rs1_in_use_o = 1'b0;
                rs2_in_use_o = 1'b0;
                pc_operand_o  = 1'b0;
            end
        endcase
    end

endmodule