`timescale 1ns / 1ps

module top_tb(

    );
    
    reg clk_s;
    reg reset_s;
    wire overflow_s;
    wire zero_s;
    
    top cpu(

        .clk(clk_s),
        .reset(reset_s),
        .overflow_o(overflow_s),
        .zero_o(zero_s)

    );
    
    // Clock generator process
    initial begin
        clk_s = 1'b0;
        forever #5 clk_s = ~clk_s;
    end
    
    // Reset process
    initial begin
        reset_s = 1'b1;
        #20 reset_s = 1'b0;
    end
    
    
endmodule