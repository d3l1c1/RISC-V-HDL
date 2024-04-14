`timescale 1ns/1ns

module control_path_tb;

    reg clk =0;

    // inputs from top module
    reg rst_n;

    // inputs from datapath
    reg[31:0] instruction_i;
    reg branch_condition_i; // used for deciging if brach should be taken\

    // outputs to datapath
    wire mem_to_reg_o;
    wire[4:0] alu_op_o;
    wire alu_src_b_o;
    wire rd_we_o;
    wire pc_next_sel_o;
    wire [3:0] data_mem_we_o;
    wire pc_operand_o;

    // signals utilized in forwarding
    wire[1:0] alu_forward_a_o;
    wire[1:0] alu_forward_b_o;
    wire branch_forward_a_o;
    wire branch_forward_b_o;

    //flush signal
    wire if_id_flush_o;

    //signals for stoping pipeline
    wire pc_en_o;
    wire if_id_en_o;

    control_path cp(clk,rst_n,instruction_i,branch_condition_i,mem_to_reg_o,alu_op_o,alu_src_b_o,rd_we_o,pc_next_sel_o,data_mem_we_o,pc_operand_o,
    alu_forward_a_o,alu_forward_b_o,branch_forward_a_o,branch_forward_b_o,if_id_flush_o,pc_en_o,if_id_en_o);

    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0,cp);
        #0 rst_n = 1'b0;
        #0 instruction_i = 32'b00000000001100010000000010110011; // add x1,x2,x3
        #0 branch_condition_i = 1'b0;
        #200;
        $finish;
    end

    always 
        #10 clk = ~clk;

    

endmodule