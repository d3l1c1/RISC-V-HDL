module reg_file #(
    parameter NUMBER_OF_REGISTERS = 32,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    // Interface 1 for reading data from bank
    input [$clog2(NUMBER_OF_REGISTERS)-1:0] rs1_address_i,
    output wire[DATA_WIDTH-1:0] rs1_data_o,
    // Interface 2 for reading data from bank
    input [$clog2(NUMBER_OF_REGISTERS)-1:0] rs2_address_i,
    output wire[DATA_WIDTH-1:0] rs2_data_o,
    // Interface for writing data into bank
    input rd_we_i,
    input [$clog2(NUMBER_OF_REGISTERS)-1:0] rd_address_i,
    input [DATA_WIDTH-1:0] rd_data_i
);

    reg [DATA_WIDTH-1:0] mem [0:NUMBER_OF_REGISTERS-1];

    integer i; // Declare loop variable outside the loop

    // Initialize memory
    initial begin
        for (i = 0; i < NUMBER_OF_REGISTERS; i = i + 1) begin
            mem[i] = {(DATA_WIDTH){1'b0}}; // Resetting register file
        end
    end

    assign rs1_data_o = mem[rs1_address_i];
    assign rs2_data_o = mem[rs2_address_i];

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            for (i = 0; i < NUMBER_OF_REGISTERS; i = i + 1) begin
                mem[i] <= {(DATA_WIDTH){1'b0}}; // Resetting register file
            end
        end
        else if (rd_we_i == 1'b1) begin
            if(rd_address_i != 5'b0) begin
                mem[rd_address_i] <= rd_data_i;
            end
        end
    end
endmodule
