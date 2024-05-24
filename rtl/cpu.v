`timescale 1ns / 1ps

module cpu(
        
        // global CPU interface
                
        input wire clk,
        input wire reset,
        output wire overflow_o,
        output wire zero_o,
        output wire if_id_flush_o,
        
        // CPU interface towards memories in top module
       
        output wire [31:0] instr_mem_address_o,
        output wire if_id_en_o,
        input wire [31:0] instr_mem_read_i,
        
        output wire [3:0] data_mem_we_o,
        output wire [31:0] data_mem_address_o,
        output wire [31:0] data_mem_write_o,
        input wire [31:0] data_mem_read_i
    );
    
    wire mem_to_reg_s;
    wire [4:0]alu_op_s;
    wire alu_src_b_s;
    wire rd_we_s;
    wire pc_next_sel_s;
    wire pc_operand_s;
    wire [1:0] alu_inverters_s;
    wire [31:0] instruction_s;
    wire branch_condition_s;
    wire [1:0] alu_forward_a_s;
    wire [1:0] alu_forward_b_s;
    wire branch_forward_a_s;
    wire branch_forward_b_s;
    wire if_id_flush_s;
    wire pc_en_s;
    wire if_id_en_s;
    
    assign if_id_en_o = if_id_en_s;
    assign if_id_flush_o = if_id_flush_s;
    
    data_path d_path( 
    // Inputs from top module
    
    .clk(clk),
    .rst(reset),
    
    // Inputs from controlpath
    .mem_to_reg_i(mem_to_reg_s),
    .alu_op_i(alu_op_s),
    .alu_src_b_i(alu_src_b_s),
    .rd_we_i(rd_we_s),
    .pc_next_sel_i(pc_next_sel_s),
    .pc_operand_i(pc_operand_s),
    .alu_inverters_i(alu_inverters_s),

    // Outputs to controlpath
    .instruction_o(instruction_s),
    .branch_condition_o(branch_condition_s),
    
    // Interface to instruction memory
    .instr_mem_address_o(instr_mem_address_o),
	.instr_mem_read_i(instr_mem_read_i),
	
	// Interface to data memory
	.data_mem_address_o(data_mem_address_o),
	.data_mem_write_o(data_mem_write_o),
	.data_mem_read_i(data_mem_read_i),

    // Signals utilized in forwarding
    .alu_forward_a_i(alu_forward_a_s),
    .alu_forward_b_i(alu_forward_b_s),
    .branch_forward_a_i(branch_forward_a_s),
    .branch_forward_b_i(branch_forward_b_s),
    
    // Flags
    .overflow_o(overflow_o),
    .zero_o(zero_o),

    // Flush signal
    .if_id_flush_i(if_id_flush_s),

    // Signals for stoping pipeline
    .pc_en_i(pc_en_s),
    .if_id_en_i(if_id_en_s)
    );
    
    control_path c_path(
     // inputs from top module
    .clk(clk),
    .rst_n(reset),

    // inputs from datapath
    .instruction_i(instruction_s),
    .branch_condition_i(branch_condition_s), // used for deciging if brach should be taken

    // outputs to datapath
    .mem_to_reg_o(mem_to_reg_s),
    .alu_op_o(alu_op_s),
    .alu_src_b_o(alu_src_b_s),
    .rd_we_o(rd_we_s),
    .pc_next_sel_o(pc_next_sel_s),
    .data_mem_we_o(data_mem_we_o),
    .pc_operand_o(pc_operand_s),
    .alu_inverters_o(alu_inverters_s),

    // signals utilized in forwarding
    .alu_forward_a_o(alu_forward_a_s),
    .alu_forward_b_o(alu_forward_b_s),
    .branch_forward_a_o(branch_forward_a_s),
    .branch_forward_b_o(branch_forward_b_s),

    //flush signal
    .if_id_flush_o(if_id_flush_s),

    //signals for stoping pipeline
    .pc_en_o(pc_en_s),
    .if_id_en_o(if_id_en_s)
    );
    
endmodule