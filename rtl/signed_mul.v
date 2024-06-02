`timescale 1ns / 1ps

module signed_mul(
        
        input wire [31:0] a_i,
        input wire [31:0] b_i,
        output wire [63:0] res_o,
        input wire clk
    
    );
    
    // Internal signals
    wire [31:0] abs_a;
    wire [31:0] abs_b;
    wire [63:0] unsigned_product;
    wire sign_a;
    wire sign_b;
    wire product_sign;

    // Extract the sign bits
    assign sign_a = a_i[31];
    assign sign_b = b_i[31];

    // Compute the absolute values
    assign abs_a = sign_a ? -a_i : a_i;
    assign abs_b = sign_b ? -b_i : b_i;

    // Use the unsigned multiplier
    unsigned_mul u_mult (
        .a_i(abs_a),
        .b_i(abs_b),
        .res_o(unsigned_product),
        .clk(clk)
    );

    // Determine the sign of the product
    assign product_sign = sign_a ^ sign_b;

    // Assign the signed product
    assign res_o = product_sign ? -unsigned_product : unsigned_product;
    
endmodule
