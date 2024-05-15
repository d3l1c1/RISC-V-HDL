module data_path(
    // inputs from top module
    input wire clk,
    input wire rst_n,
    
    // inputs from controlpath
    input wire mem_to_reg_i,
    input wire[4:0] alu_op_i,
    input wire alu_src_b_i,
    input wire rd_we_i,
    input wire pc_next_sel_i,
    input wire[3:0] data_mem_we_i,
    input wire pc_operand_i,
    input wire [1:0] alu_inverters_i,

    // outputs to controlpath
    output wire[31:0] instruction_o,
    output wire branch_condition_o,

    // signals utilized in forwarding
    input wire[1:0] alu_forward_a_i,
    input wire[1:0] alu_forward_b_i,
    input wire branch_forward_a_i,
    input wire branch_forward_b_i,

    //flush signal
    input wire if_id_flush_i,

    //signals for stoping pipeline
    input wire pc_en_i,
    input wire if_id_en_i
);

    //*********************************************
    // INSTRUCTION FETCH PHASE
    
    reg [63:0] if_id_reg;
    reg [31:0] pc_o;
    reg [31:0] mux_sel_o;
    reg [31:0] jump_address;
    reg [31:0] pc_inc_o;
    
    wire [31:0] instr_mem_o; // Output of instruction memory
    
    // Combinational logic in IF-ID phase
    always @(jump_address, pc_inc_o, pc_next_sel_i, pc_o)
    begin
        pc_inc_o = pc_o + 4;
        
        if(pc_next_sel_i) begin
            mux_sel_o = pc_inc_o;
        end
        else begin
            mux_sel_o = jump_address;
        end
    end
    
    // Program counter
    always @(posedge clk) 
    begin
        if (rst_n == 1'b1) begin
            pc_o = 32'b0;
        end
        else if (rst_n == 1'b0) begin
            if(pc_en_i == 1'b1) begin
                pc_o = mux_sel_o;
            end
        end
    end
    
    // Instruction memory instantiation
    instr_mem ins_mem (
        .clk(clk),
        .en_a_i(),
        .en_b_i(),
        .data_a_i(pc_o),
        .data_b_i(),
        .addr_a_i(),
        .addr_b_i(),
        .we_a_i(),
        .we_b_i(),
        .data_a_o(instr_mem_o),
        .data_b_o()
    );
    
    // IF-ID Register
    always @(posedge clk) 
    begin
        if(rst_n == 1'b0) begin
            if_id_reg = 64'b0;
        end
        else begin
            if_id_reg = instr_mem_o;
        end
    end

    //*********************************************
    // INSTRUCTION DECODE PHASE
    
    reg[159:0] id_ex_reg;
    wire[4:0] rd_address_s;
    wire[31:0] rd_data_s;
    wire[31:0] rs1_data_s;
    wire[31:0] rs2_data_s;
    
    reg_file register_file (
        .clk(clk),
        .rst(rst_n),
       // .rs1_address_i(if_id_reg[]),
        .rs1_data_o(rs1_data_s),
       // .rs2_address_i(if_id_reg[]),
        .rs2_data_o(rs2_data_s),
        .rd_we_i(rd_we_i),
        .rd_address_i(rd_address_s),
        .rd_data_i(rd_data_s)
    );
    
    immediate imm(
        .instruction_i(instr_mem_o),
        .immediate_extended_o() // id_ex_reg
    );
    
    reg [31:0]mux_a_res;
    reg [31:0]mux_b_res;
    
    always @(branch_forward_a_i) begin
        if(branch_forward_a_i == 1'b1)
        begin
            // forwarding iz mem faze
        end
        else begin
            mux_a_res = rs1_data_s;
        end
    end
    
   always @(branch_forward_b_i) begin
        if(branch_forward_b_i == 1'b1)
        begin
            // forwarding iz mem faze
        end
        else begin
            mux_b_res = rs2_data_s;
        end
    end
    
    assign branch_condition_o = 1'b1 ? mux_a_res == mux_b_res : 1'b0;
    
    always @(posedge clk) 
    begin
        if(rst_n == 1'b0) begin
            if_id_reg = 64'b0;
        end
        else begin
            
        end
    end
    
    //*********************************************
    // EXECUTE PHASE
    
    reg[78:0] ex_mem_reg;
    reg[31:0] alu_input_a,alu_input_b; // inputs for ALU
    reg[31:0] alu_b_tmp;
    reg[31:0] alu_out_s; // ALU output signal
    reg zero_s, overflow_s;
    
    // first fowrading mux
    
    always @*
    begin
        
        case(alu_forward_a_i)
            2'b00: alu_input_a = 1; // iz registra
            2'b01: alu_input_a = 2; // iz wb
            2'b10: alu_input_a = 3; // iz mem
            default: alu_input_a = 0;
        
        endcase
        
    end
    
   // second fowrading mux
   always @*
   begin
        
        case(alu_forward_a_i)
            2'b00: alu_b_tmp = 1; // iz registra
            2'b01: alu_b_tmp = 2; // iz wb
            2'b10: alu_b_tmp = 3; // iz mem
            default: alu_b_tmp = 0;
        
        endcase
        
    end
    
    // second mux on b before ALU
    always @ *
    begin
        
        if(alu_src_b_i == 1'b1)
        begin
            alu_input_b = 1; // iz registra
        end
        else begin 
            alu_input_b = alu_b_tmp;
        end
    
    end
    
    // ALU entity
    
    alu alu_module(
     .a_i(alu_input_a),
     .b_i(alu_input_b),
     .op_i(alu_op_i),
     .res_o(alu_out_s),
     .zero_o(zero_s),
     .of_o(overflow_s),
     .inverters_i(alu_inverters_i)
    );
    
    data_mem dat_mem (
        .clk(clk),
        .en_a_i(),
        .en_b_i(),
        .data_a_i(),
        .data_b_i(),
        .addr_a_i(),
        .addr_b_i(),
        .we_a_i(),
        .we_b_i(),
        .data_a_o(),
        .data_b_o()
    );
    
    //*********************************************
    // MEMORY ACCESS PHASE
    
    reg[75:0] mem_wb_reg;
    
    //*********************************************
    // WRITE BACK PHASE
    
endmodule
