module data_path(
    // Inputs from top module
    input wire clk,
    input wire rst_n,
    
    // Inputs from controlpath
    input wire mem_to_reg_i,
    input wire[4:0] alu_op_i,
    input wire alu_src_b_i,
    input wire rd_we_i,
    input wire pc_next_sel_i,
    input wire[3:0] data_mem_we_i,
    input wire pc_operand_i,
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

    // Flush signal
    input wire if_id_flush_i,

    // Signals for stoping pipeline
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
    
    // IF-ID Register
    always @(posedge clk) 
    begin
        if(rst_n == 1'b0) begin
            if_id_reg = 64'b0;
        end
        else begin
            if (if_id_en_i == 1'b1) begin                   /// DODAJ IF_ID_FLUSH
                if_id_reg = instr_mem_o;
            end
        end
    end

    //*********************************************
    // INSTRUCTION DECODE PHASE
    
    reg [100:0] id_ex_reg;
    wire [4:0] rd_address_s;
    wire [31:0] rd_data_s;
    wire [31:0] rs1_data_s;
    wire [31:0] rs2_data_s;
    wire [31:0] imm_o;
    
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
        .immediate_extended_o(imm_o) // id_ex_reg
    );
    
    reg [31:0] mux_a_res;
    reg [31:0] mux_b_res;
    
    // Mux A used for forwarding
    always @(branch_forward_a_i, rs1_data_s) begin
        if(branch_forward_a_i == 1'b1)
        begin
            // forwarding iz mem faze
        end
        else begin
            mux_a_res = rs1_data_s;
        end
    end
   
   // Mux B used for forwarding
   always @(branch_forward_b_i, rs2_data_s) begin
        if(branch_forward_b_i == 1'b1)
        begin
            // forwarding iz mem faze
        end
        else begin
            mux_b_res = rs2_data_s;
        end
    end
    
    // Comparator
    assign branch_condition_o = 1'b1 ? mux_a_res == mux_b_res : 1'b0;
    
    // ID_EX Register
    always @(posedge clk) 
    begin
        if(rst_n == 1'b0) begin
            id_ex_reg = 64'b0;
        end
        else begin
            id_ex_reg[31:0] = rs1_data_s;
            id_ex_reg[63:32] = rs2_data_s;
            id_ex_reg[95:64] = imm_o;
            id_ex_reg[100:96] = instr_mem_o[11:7];
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
    
    //*********************************************
    // MEMORY ACCESS PHASE
    
    reg[75:0] mem_wb_reg;
    
    //*********************************************
    // WRITE BACK PHASE
    
endmodule
