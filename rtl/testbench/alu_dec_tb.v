module alu_dec_tb;

    reg [1:0] alu_2bit_op_s;
    reg [2:0] funct3_s;
    reg [6:0] funct7_s;
    reg [4:0] rs_2_s;
    wire [1:0]invert_inputs_s;
    wire [4:0] alu_op_s; // signal that tells ALU precisely which operation to do


    alu_decoder dec(alu_2bit_op_s,funct3_s,funct7_s,rs_2_s,invert_inputs_s,alu_op_s);

    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0,alu_2bit_op_s,funct3_s,funct7_s,rs_2_s,invert_inputs_s,alu_op_s);
        #0
        alu_2bit_op_s = 2'b11; // I type
        funct3_s = 3'b000; // addi
        funct7_s = 7'b0000000; // random
        rs_2_s = 5'b00011; // random

        #20 
        alu_2bit_op_s = 2'b10; // R type
        funct3_s = 3'b101; // ror
        funct7_s = 7'b0110000; // ror
        rs_2_s = 5'b00011; // ror

        #40
        alu_2bit_op_s = 2'b11; // I type
        funct3_s = 3'b001; // clz
        funct7_s = 7'b0110000; // clz
        rs_2_s = 5'b00000; // clz

        #200;
        $finish;
    end



endmodule