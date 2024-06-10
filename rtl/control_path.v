module control_path(

    // inputs from top module
    input wire clk,
    input wire rst_n,

    // inputs from datapath
    input wire[31:0] instruction_i,
    input wire branch_condition_i, // used for deciging if brach should be taken\

    // outputs to datapath
    output wire mem_to_reg_o,
    output wire[4:0] alu_op_o,
    output wire alu_src_b_o,
    output wire rd_we_o,
    output wire pc_next_sel_o,
    output reg[3:0] data_mem_we_o,
    output wire pc_operand_o,
    output wire jalr_operand_o,
    output wire [1:0]alu_inverters_o,
    output wire stop_flag_o,

    // signals utilized in forwarding
    output wire[1:0] alu_forward_a_o,
    output wire[1:0] alu_forward_b_o,
    output wire branch_forward_a_o,
    output wire branch_forward_b_o,

    //flush signal
    output wire if_id_flush_o,

    //signals for stoping pipeline
    output wire pc_en_o,
    output wire if_id_en_o
);

    // control decoder

    reg[37:0] id_ex_reg;

    wire mem_to_reg_s;
    wire[1:0] data_mem_we_s;
    wire rd_we_s;
    wire alu_src_b_s;
    wire branch_s;
    wire[1:0] alu_2bit_op_s;
    wire rs1_in_use_s;
    wire rs2_in_use_s;
    wire pc_operand_s;
    wire stop_flag_s;
    
    wire control_pass_s;

    control_decoder cntrl_dec(
        .opcode_i(instruction_i[6:0]),
        .funct3_i(instruction_i[14:12]),
        .mem_to_reg_o(mem_to_reg_s),
        .data_mem_we_o(data_mem_we_s),
        .rd_we_o(rd_we_s),
        .alu_src_b_o(alu_src_b_s),
        .branch_o(branch_s),
        .alu_2bit_op_o(alu_2bit_op_s),
        .rs1_in_use_o(rs1_in_use_s),
        .rs2_in_use_o(rs2_in_use_s),
        .pc_operand_o(pc_operand_s),
        .stop_flag_o(stop_flag_s)
    );

    always @(posedge clk) 
    begin
        if(rst_n == 1'b1) begin
            id_ex_reg <= 38'b00000000000000000000000000000000000000;
        end
        else begin

            // TODO: CLEAN =>  remove rs1 and rs2 in use sigs

            if(control_pass_s == 1'b1) begin
                id_ex_reg[0] <= control_pass_s;
                id_ex_reg[1] <= mem_to_reg_s;
                id_ex_reg[3:2] <= data_mem_we_s;
                id_ex_reg[4] <= rd_we_s;
                id_ex_reg[5] <= alu_src_b_s;
                id_ex_reg[6] <= branch_s;
                id_ex_reg[8:7] <= alu_2bit_op_s;
                id_ex_reg[9] <= rs1_in_use_s;
                id_ex_reg[10] <= rs2_in_use_s;
                id_ex_reg[11] <= pc_operand_s;
                id_ex_reg[14:12] <= instruction_i[14:12]; // funct3
                id_ex_reg[21:15] <= instruction_i[31:25]; // funct7
                id_ex_reg[26:22] <= instruction_i[11:7]; // rd
                id_ex_reg[31:27] <= instruction_i[19:15]; // rs1
                id_ex_reg[36:32] <= instruction_i[24:20]; // rs2
                id_ex_reg[37] <= stop_flag_s;
            end
            else
            begin
                id_ex_reg <= 38'b00000000000000000000000000000000000000;  
            end
        end

    end
    
    assign jalr_operand_o = pc_operand_s;
    assign alu_src_b_o = id_ex_reg[5];
    assign pc_operand_o = id_ex_reg[11];
    assign pc_next_sel_o = branch_condition_i & branch_s;
    assign if_id_flush_o = branch_condition_i & branch_s;

    reg[9:0] ex_mem_reg;

    forwarding_unit fwd_unit(
        .rs1_address_id_i(instruction_i[19:15]),
        .rs2_address_id_i(instruction_i[24:20]),
        .rs1_address_ex_i(id_ex_reg[31:27]),
        .rs2_address_ex_i(id_ex_reg[36:32]),
        .rd_we_mem_i(ex_mem_reg[3]),
        .rd_address_mem_i(ex_mem_reg[8:4]),
        .rd_we_wb_i(mem_wb_reg[6]),
        .rd_address_wb_i(mem_wb_reg[5:1]),
        .alu_forward_a_o(alu_forward_a_o),
        .alu_forward_b_o(alu_forward_b_o),
        .branch_forward_a_o(branch_forward_a_o),
        .branch_forward_b_o(branch_forward_b_o)

    );

    alu_decoder alu_dcd(
        .alu_2bit_op_i(id_ex_reg[8:7]),
        .funct3_i(id_ex_reg[14:12]),
        .funct7_i(id_ex_reg[21:15]),
        .rs_2_i(id_ex_reg[36:32]),
        .alu_op_o(alu_op_o),
        .alu_inverters(alu_inverters_o)
    );

    always @(posedge clk) 
    begin
        if(rst_n == 1'b1) begin
            ex_mem_reg <= 10'b0000000000;
        end
        else begin
            ex_mem_reg[0] <= id_ex_reg[1]; // mem_to_reg
            ex_mem_reg[2:1] <= id_ex_reg[3:2]; // data_mem_we
            ex_mem_reg[3] <= id_ex_reg[4]; // rd_we
            ex_mem_reg[8:4] <= id_ex_reg[26:22]; // rd
            ex_mem_reg[9] <= id_ex_reg[37]; // stop flag
        end

    end


    reg[7:0] mem_wb_reg;


    always @(posedge clk) 
    begin
        if(rst_n == 1'b1) begin
            mem_wb_reg <= 8'b00000000;
        end
        else begin
            mem_wb_reg[0] <= ex_mem_reg[0]; // mem_to_reg
            mem_wb_reg[5:1] <= ex_mem_reg[8:4]; // rd
            mem_wb_reg[6] <= ex_mem_reg[3]; // rd_we
            mem_wb_reg[7] <= ex_mem_reg[9]; // stop flag
        end

    end

    always @* begin

        case(ex_mem_reg[2:1])
            2'b00: data_mem_we_o = 4'b0000;
            2'b01: data_mem_we_o = 4'b0001; // sb
            2'b10: data_mem_we_o = 4'b0011; // sh
            2'b11: data_mem_we_o = 4'b1111; //sw
            default: data_mem_we_o = 4'b0000;
        endcase

    end

    assign rd_we_o = mem_wb_reg[6];
    assign mem_to_reg_o = mem_wb_reg[0];
    assign stop_flag_o = mem_wb_reg[7];

    hazard_unit hzrd_unit(
        .rs1_address_id_i(instruction_i[19:15]),
        .rs2_address_id_i(instruction_i[24:20]),
        .rs1_in_use_i(rs1_in_use_s),
        .rs2_in_use_i(rs2_in_use_s),
        .branch_id_i(branch_s),
        .rd_address_ex_i(id_ex_reg[26:22]),
        .mem_to_reg_ex_i(id_ex_reg[1]),
        .rd_we_ex_i(id_ex_reg[4]),
        .rd_address_mem_i(ex_mem_reg[8:4]),
        .mem_to_reg_mem_i(ex_mem_reg[0]),
        .pc_en_o(pc_en_o),
        .if_id_en_o(if_id_en_o),
        .control_pass_o(control_pass_s)
    );

endmodule