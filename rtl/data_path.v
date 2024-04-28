module data_path(
    // inputs from top module
    input wire clk,
    input wire rst_n,
    
    // inputs from controlpath
    output wire mem_to_reg_i,
    output wire[4:0] alu_op_i,
    output wire alu_src_b_i,
    output wire rd_we_i,
    output wire pc_next_sel_i,
    output reg[3:0] data_mem_we_i,
    output wire pc_operand_i,

    // outputs to controlpath 
    input wire[31:0] instruction_o,
    input wire branch_condition_o,

    // signals utilized in forwarding
    output wire[1:0] alu_forward_a_i,
    output wire[1:0] alu_forward_b_i,
    output wire branch_forward_a_i,
    output wire branch_forward_b_i,

    //flush signal
    output wire if_id_flush_i,

    //signals for stoping pipeline
    output wire pc_en_i,
    output wire if_id_en_i
);
    
    // INSTRUCTION FETCH PHASE
    reg[63:0] if_id_reg;
    
    // INSTRUCTION DECODE PHASE
    reg[159:0] id_ex_reg;
    
    // EXECUTE PHASE
    reg[78:0] ex_mem_reg;
    
    // MEMORY ACCESS PHASE
    reg[75:0] mem_wb_reg;
    
    // WRITE BACK PHASE
    
endmodule
