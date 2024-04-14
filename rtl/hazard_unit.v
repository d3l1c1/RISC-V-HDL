module hazard_unit(
    // module inputs
    input wire[4:0] rs1_address_id_i,
    input wire[4:0] rs2_address_id_i,
    input wire rs1_in_use_i,
    input wire rs2_in_use_i,
    input wire branch_id_i,
    input wire[4:0] rd_address_ex_i,
    input wire mem_to_reg_ex_i,
    input wire rd_we_ex_i,
    input wire[4:0] rd_address_mem_i,
    input wire mem_to_reg_mem_i,

    // module outputs
    output reg pc_en_o,
    output reg if_id_en_o,
    output reg control_pass_o
);

    always @* begin
        pc_en_o = 1'b1;
        if_id_en_o = 1'b1;
        control_pass_o = 1'b1;

        if (branch_id_i == 1'b0) begin
            if (((rs1_address_id_i == rd_address_ex_i && rs1_in_use_i == 1'b1) || (rs2_address_id_i == rd_address_ex_i && rs2_in_use_i == 1'b1)) && mem_to_reg_ex_i == 1'b1 && rd_we_ex_i == 1'b1) begin
                pc_en_o = 1'b0;
                if_id_en_o = 1'b0;
                control_pass_o = 1'b0;
            end
        end
        else if (branch_id_i == 1'b1) begin
            
            if ((rs1_address_id_i == rd_address_ex_i || rs2_address_id_i == rd_address_ex_i) && rd_we_ex_i == 1'b1) begin
                pc_en_o = 1'b0;
                if_id_en_o = 1'b0;
                control_pass_o = 1'b0;
            end
            else if ((rs1_address_id_i == rd_address_mem_i || rs2_address_id_i == rd_address_mem_i) && mem_to_reg_mem_i == 1'b1) begin
                pc_en_o = 1'b0;
                if_id_en_o = 1'b0;
                control_pass_o = 1'b0;
            end
            
        end
    end
endmodule
