module data_path(
    // Inputs from top module
    input wire clk,
    input wire rst,
    
    // Inputs from controlpath
    input wire mem_to_reg_i,
    input wire[4:0] alu_op_i,
    input wire alu_src_b_i,
    input wire rd_we_i,
    input wire pc_next_sel_i,
    input wire pc_operand_i,
    input wire jalr_operand_i,
    input wire [1:0] alu_inverters_i,

    // Outputs to controlpath
    output wire [31:0] instruction_o,
    output wire branch_condition_o,
    
    // Interface to instruction memory
    output wire [31:0] instr_mem_address_o,
	input wire [31:0] instr_mem_read_i,
	
	// Interface to data memory
	output wire [31:0] data_mem_address_o,
	output wire [31:0] data_mem_write_o,
	input wire [31:0] data_mem_read_i,

    // Signals utilized in forwarding
    input wire[1:0] alu_forward_a_i,
    input wire[1:0] alu_forward_b_i,
    input wire branch_forward_a_i,
    input wire branch_forward_b_i,
    
    // Flags
    output wire overflow_o,
    output wire zero_o,

    // Flush signal
    input wire if_id_flush_i,

    // Signals for stoping pipeline
    input wire pc_en_i,
    input wire if_id_en_i
);

    //*********************************************
    // INSTRUCTION FETCH PHASE
    
    reg [31:0] if_id_reg;
    reg [31:0] pc_o;
    reg [31:0] mux_sel_o;
    reg [31:0] jump_address;
    wire [31:0] pc_inc_o;
    wire [31:0] instr_mem_o;
    
    // Combinational logic in IF phase
    always @*
    begin
        if(pc_next_sel_i == 1'b0) begin
            mux_sel_o = pc_inc_o;
        end
        else begin
            mux_sel_o = jump_address;
        end
    end
    
    assign pc_inc_o = pc_o + 4; // return to +4
    
    // Program counter
    always @(posedge clk) 
    begin
        if (rst == 1'b1) begin
            pc_o <= 32'b0;
        end
        else begin
            if(pc_en_i == 1'b1) begin
                pc_o <= mux_sel_o;
            end
        end
    end
    
    assign instr_mem_address_o = pc_o;
    assign instr_mem_o = instr_mem_read_i;
    
    // IF-ID Register
    always @(posedge clk) 
    begin
        if(rst == 1'b1) begin
            if_id_reg <= 64'b0;
        end
        else begin
            if (if_id_en_i == 1'b1) begin
                if (if_id_flush_i == 1'b1) begin
                    if_id_reg <= 32'b0;
                end
                else begin
                    if_id_reg <= pc_o;     
                end
            end
        end
    end

    //*********************************************
    // INSTRUCTION DECODE PHASE
    
    reg [132:0] id_ex_reg;
    wire [4:0] rd_address_s;
    reg [31:0] rd_data_s;
    wire [31:0] rs1_data_s;
    wire [31:0] rs2_data_s;
    wire [31:0] imm_o;
    
    reg_file register_file (
        .clk(clk),
        .rst(rst),
        .rs1_address_i(instr_mem_o[19:15]),
        .rs1_data_o(rs1_data_s),
        .rs2_address_i(instr_mem_o[24:20]),
        .rs2_data_o(rs2_data_s),
        .rd_we_i(rd_we_i),
        .rd_address_i(rd_address_s),
        .rd_data_i(rd_data_s)
    );
    
    immediate imm(
        .instruction_i(instr_mem_o),
        .immediate_extended_o(imm_o)
    );
    
    reg [31:0] mux_a_res;
    reg [31:0] mux_b_res;
    wire [31:0] mem_fwd_s;
    
    // Instruction output to control path
    assign instruction_o = instr_mem_o;
    
    // Multiplexers used for forwarding
    always @*
    begin
        if(branch_forward_a_i == 1'b1)
        begin
            mux_a_res = mem_fwd_s;
        end
        else begin
            mux_a_res = rs1_data_s;
        end
        
        if(branch_forward_b_i == 1'b1)
        begin
            mux_b_res = mem_fwd_s;
        end
        else begin
            mux_b_res = rs2_data_s;
        end
    end
    
    // Logic for calculating branching address
    always @*
    begin
        if (jalr_operand_i == 1'b0) begin
            jump_address = (imm_o + if_id_reg);
        end
        else begin
            jump_address = (imm_o + rs1_data_s);    // JALR instruction
        end
    end
    
    // Branching module to cover all types of branches
    branch_module branch(
        .operand1(mux_a_res),
        .operand2(mux_b_res),
        .opcode_i(instr_mem_o[6:0]),
        .funct3_i(instr_mem_o[14:12]),
        .branch_condition_o(branch_condition_o)
    );
    
    // ID_EX Register
    always @(posedge clk) 
    begin
        if(rst == 1'b1) begin
            id_ex_reg <= 132'b0;
        end
        else begin
            id_ex_reg[31:0] <= rs1_data_s;
            id_ex_reg[63:32] <= rs2_data_s;
            id_ex_reg[95:64] <= imm_o;
            id_ex_reg[100:96] <= instr_mem_o[11:7];
            id_ex_reg[132:101] <= if_id_reg;
        end
    end
    
    //*********************************************
    // EXECUTE PHASE
    
    reg [68:0] ex_mem_reg;
    reg [31:0] alu_input_a, alu_input_b; // inputs for ALU
    reg [31:0] alu_a_tmp, alu_b_tmp;
    reg [31:0] alu_a_inv, alu_b_inv;
    wire [31:0] alu_out_s; // ALU output signal
    
    // Combinational logic of EX phase
    always @*
    begin
        case(alu_forward_a_i)
            2'b00: alu_a_tmp = id_ex_reg[31:0];
            2'b01: alu_a_tmp = rd_data_s;
            2'b10: alu_a_tmp = mem_fwd_s;
            default: alu_a_tmp = 0;
        endcase
        
        case(alu_forward_b_i)
            2'b00: alu_b_tmp = id_ex_reg[63:32];
            2'b01: alu_b_tmp = rd_data_s;
            2'b10: alu_b_tmp = mem_fwd_s;
            default: alu_b_tmp = 0;
        endcase
    end
    
    // Second multiplexers before ALU
    always @*
    begin
        // Used for AUIPC
        if(pc_operand_i == 1'b1)
        begin
            alu_a_inv = id_ex_reg[132:101];
        end
        else begin 
            alu_a_inv = alu_a_tmp;
        end
        
        //Used for immediate instructions
        if(alu_src_b_i == 1'b1)
        begin
            alu_b_inv = id_ex_reg[95:64];
        end
        else begin 
            alu_b_inv = alu_b_tmp;
        end
    end
    
    // Combinational logic for inverting ALU inputs
    always @*
    begin
        case(alu_inverters_i)
            2'b00: begin
                alu_input_a = alu_a_inv;
                alu_input_b = alu_b_inv;
            end
            2'b01: begin
                alu_input_a = ~alu_a_inv;
                alu_input_b = alu_b_inv;
            end
            2'b10: begin
                alu_input_a = alu_a_inv;
                alu_input_b = ~alu_b_inv;
            end
            default: begin
                alu_input_a = ~alu_a_inv;
                alu_input_b = alu_b_inv;
            end
        endcase
    end
    
    alu alu_module(
     .a_i(alu_input_a),
     .b_i(alu_input_b),
     .op_i(alu_op_i),
     .res_o(alu_out_s),
     .zero_o(zero_o),
     .of_o(overflow_o),
     .clk(clk)
    );
    
    // EX_MEM Register
    always @(posedge clk) 
    begin
        if(rst == 1'b1) begin
            ex_mem_reg <= 68'b0;
        end
        else begin
            ex_mem_reg[31:0] <= alu_out_s;
            ex_mem_reg[63:32] <= id_ex_reg[63:32];
            ex_mem_reg[68:64] <= id_ex_reg[100:96];
        end
    end
    
    //*********************************************
    // MEMORY ACCESS PHASE
    
    reg [36:0] mem_wb_reg;
    wire [31:0] data_mem_o;
    
    // Interface with data memory
    assign data_mem_address_o = ex_mem_reg[31:0];
	assign data_mem_write_o = ex_mem_reg[63:32];
    assign data_mem_o = data_mem_read_i;
    
    // Forwarding signal from MEM phase
    assign mem_fwd_s = ex_mem_reg[31:0];
    
    // MEM_WB Register
    always @(posedge clk) 
    begin
        if(rst == 1'b1) begin
            mem_wb_reg <= 36'b0;
        end
        else begin
            mem_wb_reg[31:0] <= ex_mem_reg[31:0];
            mem_wb_reg[36:32] <= ex_mem_reg[68:64];
        end
    end
    
    //*********************************************
    // WRITE BACK PHASE
    
    // WB multiplexer for rd_data
    always @*
    begin
        if (mem_to_reg_i) begin
            rd_data_s = data_mem_o;
        end
        else begin
            rd_data_s = mem_wb_reg[31:0];
        end
    end
    
    // Writing back rd_address
    assign rd_address_s = mem_wb_reg[36:32];
    
endmodule