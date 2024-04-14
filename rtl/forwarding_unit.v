module forwarding_unit(

    // signals from ID phaes 
    input wire[4:0] rs1_address_id_i,
    input wire[4:0] rs2_address_id_i,

    // signals from EX phase 
    input wire[4:0] rs1_address_ex_i,
    input wire[4:0] rs2_address_ex_i,

    // signals from MEM phase 
    input wire rd_we_mem_i,
    input wire[4:0] rd_address_mem_i,

    // signals from WB phase
    input wire rd_we_wb_i,
    input wire[4:0] rd_address_wb_i,

    // control signals for ALU input selection MUXes
    output wire[1:0] alu_forward_a_o,
    output wire[1:0] alu_forward_b_o,

    // signals for controling conditional branches
    output wire branch_forward_a_o,
    output wire branch_forward_b_o
);

  assign alu_forward_a_o = (rd_we_wb_i && (rs1_address_ex_i == rd_address_wb_i)) ? 2'b01 : 
                             (rd_we_mem_i && (rs1_address_ex_i == rd_address_mem_i)) ? 2'b10 : 2'b00;

    assign alu_forward_b_o = (rd_we_wb_i && (rs2_address_ex_i == rd_address_wb_i)) ? 2'b01 : 
                             (rd_we_mem_i && (rs2_address_ex_i == rd_address_mem_i)) ? 2'b10 : 2'b00;

    assign branch_forward_a_o = (rd_we_mem_i && (rs1_address_id_i == rd_address_mem_i)) ? 1'b1 : 1'b0;
    assign branch_forward_b_o = (rd_we_mem_i && (rs2_address_id_i == rd_address_mem_i)) ? 1'b1 : 1'b0;

endmodule