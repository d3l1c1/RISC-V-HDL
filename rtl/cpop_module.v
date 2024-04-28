module cpop_module #(
    parameter DATA_WIDTH = 32
) (
    input [DATA_WIDTH-1:0] in,
    output reg [DATA_WIDTH-1:0] out
);

reg [DATA_WIDTH-1:0] tmpOut;
reg [DATA_WIDTH-1:0] tmpIn;

    always @* begin
        tmpIn = in;
        // tmpOut is now a set of 2-bit sums of the number of ones
        tmpOut = ((tmpIn & 32'hAAAAAAAA) >> 1) + (tmpIn & 32'h55555555);
        // x is now a set of 4-bit sums of the number of ones
        tmpIn = ((tmpOut & 32'hCCCCCCCC) >> 2) + (tmpOut & 32'h33333333);
        // tmpOut is now a set of 8-bit sums of the number of ones
        tmpOut = ((tmpIn & 32'hF0F0F0F0) >> 4) + (tmpIn & 32'h0F0F0F0F);
        // x is now a set of 16-bit sums of the number of ones
        tmpIn = ((tmpOut & 32'hFF00FF00) >> 8) + (tmpOut & 32'h00FF00FF);
        // tmpOut is now the 32-bit sum of the number of ones
        tmpOut = (tmpIn >> 16) + (tmpIn & 32'h0000FFFF);

        out = tmpOut;
    end    
endmodule
