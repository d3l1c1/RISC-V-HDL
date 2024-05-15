module instr_mem #(parameter WADDR = 10)
(
    input wire clk,
    input wire en_a_i,
    input wire en_b_i,
    input wire [31:0] data_a_i,
    input wire [31:0] data_b_i,
    input wire [WADDR - 1:0] addr_a_i,
    input wire [WADDR - 1:0] addr_b_i,
    input wire [3:0] we_a_i,
    input wire [3:0] we_b_i,
    output reg [31:0] data_a_o,
    output reg [31:0] data_b_o
);

reg [7:0] ram_s [(2 ** WADDR) - 1:0];

// Synchronous Write
always @(posedge clk) begin
    if (en_a_i) begin
        if (we_a_i[3]) ram_s[addr_a_i + 3] <= data_a_i[31:24];
        if (we_a_i[2]) ram_s[addr_a_i + 2] <= data_a_i[23:16];
        if (we_a_i[1]) ram_s[addr_a_i + 1] <= data_a_i[15:8];
        if (we_a_i[0]) ram_s[addr_a_i] <= data_a_i[7:0];
    end
    if (en_b_i) begin
        if (we_b_i[3]) ram_s[addr_b_i + 3] <= data_b_i[31:24];
        if (we_b_i[2]) ram_s[addr_b_i + 2] <= data_b_i[23:16];
        if (we_b_i[1]) ram_s[addr_b_i + 1] <= data_b_i[15:8];
        if (we_b_i[0]) ram_s[addr_b_i] <= data_b_i[7:0];
    end
end

// Asynchronous Read
always @* begin
    if (en_a_i) begin
        data_a_o[31:24] = ram_s[addr_a_i + 3];
        data_a_o[23:16] = ram_s[addr_a_i + 2];
        data_a_o[15:8] = ram_s[addr_a_i + 1];
        data_a_o[7:0] = ram_s[addr_a_i];
    end
    if (en_b_i) begin
        data_b_o[31:24] = ram_s[addr_b_i + 3];
        data_b_o[23:16] = ram_s[addr_b_i + 2];
        data_b_o[15:8] = ram_s[addr_b_i + 1];
        data_b_o[7:0] = ram_s[addr_b_i];
    end
end

endmodule
