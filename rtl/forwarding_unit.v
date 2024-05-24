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
    
    reg [1:0] alu_forward_a_s;
    reg [1:0] alu_forward_b_s;
    reg branch_forward_a_s;
    reg branch_forward_b_s;
    
    assign alu_forward_a_o = alu_forward_a_s;
    assign alu_forward_b_o = alu_forward_b_s;
    assign branch_forward_a_o = branch_forward_a_s;
    assign branch_forward_b_o = branch_forward_b_s;
    
    // Forwarding to alu
    always @*
    begin
        alu_forward_a_s = 2'b00;
        alu_forward_b_s = 2'b00;
    
        if (rd_we_wb_i && rd_address_wb_i != 5'b0) begin
            if (rs1_address_ex_i == rd_address_wb_i) begin
                alu_forward_a_s = 2'b01;
            end
            
            if (rs2_address_ex_i == rd_address_wb_i) begin
                alu_forward_b_s = 2'b01;
            end
        end
        
        if (rd_we_mem_i && rd_address_mem_i != 5'b0) begin
            if (rs1_address_ex_i == rd_address_mem_i) begin
                alu_forward_a_s = 2'b10;
            end
            
            if (rs2_address_ex_i == rd_address_mem_i) begin
                alu_forward_b_s = 2'b10;
            end
        end
    end
    
    // Forwarding to branch muxes
    always @*
    begin
        branch_forward_a_s = 1'b0;
        branch_forward_b_s = 1'b0;
    
        if (rd_we_mem_i && rd_address_mem_i != 5'b0) begin
            if (rs1_address_id_i == rd_address_mem_i) begin
                branch_forward_a_s = 1'b1;
            end
            
            if (rs2_address_id_i == rd_address_mem_i) begin
                branch_forward_b_s = 1'b1;
            end
        end
    end
endmodule